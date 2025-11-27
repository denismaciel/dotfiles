local Job = require('plenary.job')
local M = {}
local vim = vim or {}

local timeout_ms = 10000
local active_job = nil
local decode_error_reported = false

local function notify_error(message)
    vim.schedule(function()
        vim.notify(message, vim.log.levels.ERROR, { title = 'llm.nvim' })
    end)
end

local read_env = function(name)
    local file = io.open(name, 'r')
    if file then
        local content = file:read('*all')
        file:close()
        -- Trim whitespace and newlines
        content = content:gsub('^%s*(.-)%s*$', '%1')
        return content
    end

    local content = os.getenv(name)
    if content then
        return content
    end
    notify_error('Environment variable not found: ' .. name)
end

local service_lookup = {
    openai = {
        url = 'https://api.openai.com/v1/chat/completions',
        model = 'gpt-4o',
        api_key_name = '/home/denis/credentials/openai-api-key',
    },
    anthropic = {
        url = 'https://api.anthropic.com/v1/messages',
        model = 'claude-opus-4-20250514',
        -- model = 'claude-3-7-sonnet-20250219',
        -- model = 'claude-3-5-sonnet-20240620',
        api_key_name = '/home/denis/credentials/anthropic-api-key',
    },
    gemini = {
        url = 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions',
        model = 'gemini-2.5-pro',
        api_key_name = '/home/denis/credentials/gemini-api-key',
    },
}

local system_prompt = [[ - Keep concise and use markdown. ]]

local system_prompt_replace =
    'Follow the instructions in the code comments. Generate code only. Think step by step. If you must speak, do so in comments. Generate valid code only.'

local print_prompt = false

function M.setup(opts)
    timeout_ms = opts.timeout_ms or timeout_ms
    if opts.services then
        for key, service in pairs(opts.services) do
            service_lookup[key] = service
        end
    end
    if opts.system_prompt then
        system_prompt = opts.system_prompt
    end
    if opts.system_prompt_replace then
        system_prompt_replace = opts.system_prompt_replace
    end

    if opts.print_prompt then
        print_prompt = opts.print_prompt
    end
end

local function get_buffer_path()
    local buffer = vim.api.nvim_get_current_buf()
    local buffer_name = vim.api.nvim_buf_get_name(buffer)
    local cwd = vim.fn.getcwd()
    return vim.fn.fnamemodify(buffer_name, ':.' .. cwd .. ':')
end

local function get_file_contents(file_path)
    local cwd = vim.fn.getcwd()
    local contents = ''

    if file_path then
        local full_path
        if file_path:sub(1, 1) == '/' then
            full_path = file_path
        elseif file_path:sub(1, 2) == '~/' then
            full_path = os.getenv('HOME') .. file_path:sub(2)
        elseif file_path:sub(1, 2) == './' then
            full_path = cwd .. file_path:sub(2)
        else
            full_path = cwd .. '/' .. file_path
        end
        local file = io.open(full_path, 'r')
        if file then
            local content = file:read('*all')
            file:close()

            local relative_path =
                vim.fn.fnamemodify(full_path, ':.' .. cwd .. ':')
            contents = contents
                .. string.rep('=', 15)
                .. ' '
                .. relative_path
                .. ' '
                .. string.rep('=', 15)
                .. '\n'
            contents = contents .. content .. '\n\n'
        else
            notify_error('Cannot open file: ' .. full_path)
        end
    end

    return contents
end

local function get_lines(opts)
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_window = vim.api.nvim_get_current_win()
    local cursor_position = vim.api.nvim_win_get_cursor(current_window)
    local row
    if opts.all then
        row = -1
    else
        row = cursor_position[1]
    end

    local all_lines = vim.api.nvim_buf_get_lines(current_buffer, 0, row, true)
    local lines = {}
    local file_contents = ''

    for _, line in ipairs(all_lines) do
        local file_path = line:match('^@(.+)$')
        if file_path then
            file_contents = file_contents .. get_file_contents(file_path)
        else
            table.insert(lines, line)
        end
    end

    local relative_path = get_buffer_path()

    local header = string.rep('=', 15)
        .. ' '
        .. relative_path
        .. ' '
        .. string.rep('=', 15)

    table.insert(lines, 1, header)

    return file_contents .. table.concat(lines, '\n')
end

local function write_string_at_cursor(str)
    local current_window = vim.api.nvim_get_current_win()
    local cursor_position = vim.api.nvim_win_get_cursor(current_window)
    local row, col = cursor_position[1], cursor_position[2]

    local lines = vim.split(str, '\n')
    vim.api.nvim_put(lines, 'c', true, true)

    local num_lines = #lines
    local last_line_length = #lines[num_lines]
    vim.api.nvim_win_set_cursor(
        current_window,
        { row + num_lines - 1, col + last_line_length }
    )
end

local function process_data_lines(line, service, process_data)
    local json = line:match('^data:%s*(.+)$')
    if not json then
        return false
    end
    if json == '[DONE]' then
        return true
    end
    local ok, data = pcall(vim.json.decode, json)
    if not ok then
        if not decode_error_reported then
            decode_error_reported = true
            local snippet = #json > 200 and (json:sub(1, 200) .. '...') or json
            notify_error('Failed to parse LLM stream: ' .. snippet)
        end
        return false
    end
    local stop = service == 'anthropic' and data.type == 'message_stop'
    if stop then
        return true
    end
    vim.schedule(function()
        vim.cmd('undojoin')
        process_data(data)
    end)
    return false
end

local function process_sse_response(buffer, service)
    for line in buffer:gmatch('[^\r\n]+') do
        local stop = process_data_lines(line, service, function(data)
            local content
            if service == 'anthropic' then
                if data.delta and data.delta.text then
                    content = data.delta.text
                end
            else
                if
                    data.choices
                    and data.choices[1]
                    and data.choices[1].delta
                then
                    local delta_content = data.choices[1].delta.content
                    if type(delta_content) == 'string' then
                        content = delta_content
                    elseif type(delta_content) == 'table' then
                        local pieces = {}
                        for _, block in ipairs(delta_content) do
                            if type(block) == 'string' then
                                table.insert(pieces, block)
                            elseif
                                type(block) == 'table'
                                and block.type == 'text'
                                and block.text
                            then
                                table.insert(pieces, block.text)
                            end
                        end
                        if #pieces > 0 then
                            content = table.concat(pieces, '')
                        end
                    end
                end
            end
            if content and content ~= vim.NIL then
                write_string_at_cursor(content)
            end
        end)
        if stop then
            break
        end
    end
end

local function build_prompt(opts)
    local replace = opts.replace
    local all_text = get_lines({ all = true })
    local prompt = ''
    local visual_lines = M.get_selection()

    if visual_lines then
        prompt = table.concat(visual_lines, '\n')
        if replace then
            local selection = prompt
            prompt = all_text
                .. '\n============ code to replace from '
                .. get_buffer_path()
                .. ' ============\n'
                .. selection
        else
            local selection = prompt
            prompt = all_text
                .. '\n============ answer comments in this snippet from '
                .. get_buffer_path()
                .. ' ============\n'
                .. selection
                .. '\n=======================\n'
                .. 'talk in comments only. do NOT use markdown. remember TALK IN COMMENTS ONLY'
        end
    else
        prompt = get_lines({ all = false })
    end

    local sys_prompt = replace and system_prompt_replace or system_prompt
    return sys_prompt, prompt
end

function M.prompt(opts)
    local replace = opts.replace
    local service = opts.service
    local sys_prompt, prompt = build_prompt(opts)

    local visual_lines = M.get_selection()
    if visual_lines then
        if replace then
            vim.api.nvim_command('normal! d')
            vim.api.nvim_command('normal! k')
        else
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes('<Esc>', false, true, true),
                'nx',
                false
            )
        end
    end

    local url = ''
    local model = ''
    local api_key_name = ''

    local found_service = service_lookup[service]
    if found_service then
        url = found_service.url
        api_key_name = found_service.api_key_name
        model = found_service.model
    else
        notify_error('Invalid service: ' .. tostring(service))
        return
    end

    decode_error_reported = false
    local api_key = read_env(api_key_name)
    if not api_key or api_key == '' then
        notify_error(
            'API key not found for service '
                .. service
                .. ' (expected at '
                .. api_key_name
                .. ')'
        )
        return
    end

    local data
    if print_prompt then
        print(sys_prompt)
        print(prompt)
    end

    if service == 'anthropic' then
        data = {
            system = sys_prompt,
            messages = {
                {
                    role = 'user',
                    content = prompt,
                },
            },
            model = model,
            stream = true,
            max_tokens = 4096,
        }
    else
        data = {
            messages = {
                {
                    role = 'system',
                    content = sys_prompt,
                },
                {
                    role = 'user',
                    content = prompt,
                },
            },
            model = model,
            temperature = 0.7,
            stream = true,
        }
    end

    local args = {
        '-N',
        '--fail-with-body',
        '-X',
        'POST',
        '-H',
        'Content-Type: application/json',
        '-d',
        vim.json.encode(data),
    }

    if api_key then
        if service == 'anthropic' then
            table.insert(args, '-H')
            table.insert(args, 'x-api-key: ' .. api_key)
            table.insert(args, '-H')
            table.insert(args, 'anthropic-version: 2023-06-01')
        else
            table.insert(args, '-H')
            table.insert(args, 'Authorization: Bearer ' .. api_key)
        end
    end

    table.insert(args, url)
    if active_job then
        active_job:shutdown()
        active_job = nil
    end

    local stderr_lines = {}
    active_job = Job:new({
        command = 'curl',
        args = args,
        on_stdout = function(_, out)
            process_sse_response(out, service)
        end,
        on_stderr = function(_, err)
            if err and err ~= '' then
                table.insert(stderr_lines, err)
            end
        end,
        on_exit = function(_, code)
            active_job = nil
            if code ~= 0 then
                local stderr_msg = table.concat(stderr_lines, '\n')
                local suffix = stderr_msg ~= '' and (': ' .. stderr_msg) or ''
                notify_error(
                    ('llm request failed (curl exit %d)%s'):format(code, suffix)
                )
            end
        end,
    })

    active_job:start()
    vim.api.nvim_command('normal! o')
end

function M.get_selection()
    local is_motion = _G.op_func_llm_prompt ~= nil
    local start_mark, end_mark
    if is_motion then
        start_mark = '\'['
        end_mark = '\']'
    else
        start_mark = 'v'
        end_mark = '.'
    end
    local _, srow, scol = unpack(vim.fn.getpos(start_mark))
    local _, erow, ecol = unpack(vim.fn.getpos(end_mark))

    -- visual line mode
    if vim.fn.mode() == 'V' or is_motion then
        if srow > erow then
            return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
        else
            return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
        end
    end

    -- regular visual mode
    if vim.fn.mode() == 'v' then
        if srow < erow or (srow == erow and scol <= ecol) then
            return vim.api.nvim_buf_get_text(
                0,
                srow - 1,
                scol - 1,
                erow - 1,
                ecol,
                {}
            )
        else
            return vim.api.nvim_buf_get_text(
                0,
                erow - 1,
                ecol - 1,
                srow - 1,
                scol,
                {}
            )
        end
    end

    -- visual block mode
    if vim.fn.mode() == '\22' then
        local lines = {}
        if srow > erow then
            srow, erow = erow, srow
        end
        if scol > ecol then
            scol, ecol = ecol, scol
        end
        for i = srow, erow do
            table.insert(
                lines,
                vim.api.nvim_buf_get_text(
                    0,
                    i - 1,
                    math.min(scol - 1, ecol),
                    i - 1,
                    math.max(scol - 1, ecol),
                    {}
                )[1]
            )
        end
        return lines
    end
end

function M.inspect_prompt(opts)
    local service = opts.service or 'anthropic'
    local sys_prompt, prompt = build_prompt(opts)

    -- Create new buffer to display the rendered prompt
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

    -- Format the prompt content
    local content = {
        '# LLM Prompt Inspection',
        '',
        '## Service: ' .. service,
        '## Model: '
            .. (
                service_lookup[service] and service_lookup[service].model
                or 'unknown'
            ),
        '',
        '## System Prompt:',
        '```',
    }

    -- Split system prompt into lines
    for line in sys_prompt:gmatch('[^\r\n]+') do
        table.insert(content, line)
    end

    table.insert(content, '```')
    table.insert(content, '')
    table.insert(content, '## User Prompt:')
    table.insert(content, '```')

    -- Split user prompt into lines
    for line in prompt:gmatch('[^\r\n]+') do
        table.insert(content, line)
    end

    table.insert(content, '```')

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    vim.api.nvim_command('split')
    vim.api.nvim_win_set_buf(0, buf)
end

function M.prompt_operatorfunc(opts)
    local old_func = vim.go.operatorfunc
    _G.op_func_llm_prompt = function()
        require('llm').prompt(opts)
        vim.go.operatorfunc = old_func
        _G.op_func_llm_prompt = nil
    end
    vim.go.operatorfunc = 'v:lua.op_func_llm_prompt'
    vim.api.nvim_feedkeys('g@', 'n', false)
end

return M
