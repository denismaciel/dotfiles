require('leisi')
require('config')
require('dennich')
require('dennich.note').setup()
require('dennich.llm').setup({})

vim.filetype.add({
    extension = {
        mdx = 'markdown',
    },
})

local function convert_to_apy()
    -- Get the visual selection
    local start_line = vim.fn.line('\'<')
    local end_line = vim.fn.line('\'>')
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    -- Find the separator
    local separator_index = nil
    for i, line in ipairs(lines) do
        if line:match('^%-%-%-$') then
            separator_index = i
            break
        end
    end

    if not separator_index then
        vim.api.nvim_err_writeln('No \'---\' separator found in selection')
        return
    end

    -- Extract front and back parts
    local front_lines = {}
    local back_lines = {}

    for i = 1, separator_index - 1 do
        table.insert(front_lines, lines[i])
    end

    for i = separator_index + 1, #lines do
        table.insert(back_lines, lines[i])
    end

    -- Join lines for front
    local front = table.concat(front_lines, '\n')

    -- Escape double quotes in the content
    front = front:gsub('"', '\\"')

    -- Build the command parts
    local result_lines = {}
    table.insert(result_lines, string.format('apy add-single "%s" "', front))

    -- Add the back part lines directly (preserving multiline)
    for i, line in ipairs(back_lines) do
        local escaped_line = line:gsub('"', '\\"')
        if i == #back_lines then
            table.insert(result_lines, escaped_line .. '"')
        else
            table.insert(result_lines, escaped_line)
        end
    end

    -- Replace the selection with the command
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, result_lines)
end

-- Map to a key in visual mode
vim.keymap.set('v', '<leader>apy', convert_to_apy, { silent = true })

local function split_on_periods()
    -- Get the visual selection
    local start_line = vim.fn.line('\'<')
    local end_line = vim.fn.line('\'>')
    local start_col = vim.fn.col('\'<')
    local end_col = vim.fn.col('\'>')

    -- Get the selected text
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    if #lines == 0 then
        return
    end

    -- Handle single line selection
    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
    else
        -- Handle multi-line selection
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end

    -- Join all lines into a single string
    local text = table.concat(lines, ' ')

    -- Split on periods and process each segment
    local segments = {}
    local current_segment = ''
    local i = 1

    while i <= #text do
        local char = string.sub(text, i, i)
        current_segment = current_segment .. char

        if char == '.' then
            -- Found a period, add the segment
            local trimmed = current_segment:match('^%s*(.-)%s*$') -- trim whitespace
            if trimmed ~= '' then
                table.insert(segments, trimmed)
            end
            current_segment = ''
        end
        i = i + 1
    end

    -- Add any remaining text (without period)
    if current_segment ~= '' then
        local trimmed = current_segment:match('^%s*(.-)%s*$')
        if trimmed ~= '' then
            table.insert(segments, trimmed)
        end
    end

    -- If no segments were created, return original text
    if #segments == 0 then
        return
    end

    -- Get the indentation from the first line
    local first_line_full =
        vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
    local indent = first_line_full:match('^(%s*)')

    -- Create the result lines with proper indentation
    local result_lines = {}
    for i, segment in ipairs(segments) do
        if i == 1 then
            table.insert(result_lines, indent .. segment)
        else
            table.insert(result_lines, indent .. segment)
        end
    end

    -- Replace the selection with the split lines
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, result_lines)
end

vim.keymap.set('v', '<leader>sp', split_on_periods, {
    silent = true,
    desc = 'Split selection on periods',
})

vim.keymap.set('n', '<leader>g,g', function()
    require('dennich.llm').prompt({
        replace = false,
        service = 'gemini',
    })
end, { desc = 'Prompt with Gemini' })
vim.keymap.set('n', '<leader>g,c', function()
    require('dennich.llm').prompt({
        replace = false,
        service = 'anthropic',
    })
end, { desc = 'Prompt with Claude' })
vim.keymap.set('n', '<leader>g,o', function()
    require('dennich.llm').prompt({
        replace = false,
        service = 'openai',
    })
end, { desc = 'Prompt with OpenAI' })
vim.keymap.set('n', '<leader>g,r', function()
    require('dennich.llm').inspect_prompt({
        service = 'anthropic',
        replace = false,
    })
end, { desc = 'Inspect LLM prompt' })
