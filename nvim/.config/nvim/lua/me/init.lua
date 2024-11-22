local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

local function scandir(directory)
    local i, t = 0, {}
    local pfile = io.popen('ls -a "' .. directory .. '"')

    if pfile == nil then
        return
    end

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end

    pfile:close()
    return t
end

M.highlight_markdown_titles = function()
    local palette = require('no-clown-fiesta.palette')
    vim.api.nvim_set_hl(0, '@markup.heading.1', { fg = palette.blue })
    vim.api.nvim_set_hl(0, '@markup.heading.2', { fg = palette.green })
    vim.api.nvim_set_hl(0, '@markup.heading.3', { fg = palette.red })
    vim.api.nvim_set_hl(0, '@markup.heading.4', { fg = palette.orange })
    vim.api.nvim_set_hl(0, '@markup.heading.5', { fg = palette.yellow })
end

M.insert_text = function(opts)
    local cb = vim.api.nvim_get_current_buf()
    local cline, _ = unpack(vim.api.nvim_win_get_cursor(0))
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = 'Insert Block',
            finder = finders.new_table({
                results = {
                    {
                        title = 'Routine',
                        content = {
                            '- [ ] #routine 10 min for chores',
                            '- [ ] #routine Anki',
                            '- [ ] #routine Notion BOD',
                            '- [ ] #routine Email Inbox Zero',
                            '- [ ] #routine Check Dagster',
                            '- [ ] #routine Checar Kinderpedia',
                            '- [ ] #routine Plan the day',
                            '- [ ] #routine Notion EOD',
                        },
                    },
                    {
                        title = 're:cap: collect todos',
                        content = {
                            '- [ ] 1on1',
                            '    - [ ] Arne',
                            '    - [ ] Henrqiue',
                            '    - [ ] Maria',
                            '    - [ ] Mariana',
                            '    - [ ] Simon',
                            '    - [ ] Tom',
                            '    - [ ] Data weekly',
                        },
                    },
                    {
                        title = 'LLM: code only, command only',
                        content = {
                            'Output only the command/code, do not write any explanation.',
                        },
                    },
                },
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.title,
                        ordinal = entry.title,
                    }
                end,
            }),
            -- previewer = conf.file_previewer(opts), -- TODO: implement a previewr
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.api.nvim_buf_set_lines(
                        cb,
                        cline,
                        cline,
                        false,
                        selection.value.content
                    )
                end)
                return true
            end,
        })
        :find()
end

M.center_and_change_colorscheme = function()
    vim.cmd([[ normal Gzz ]])
    -- vim.cmd([[ colorscheme tokyonight ]])
    -- M.highlight_markdown_titles()
end

M.is_shorts_mode = function()
    local is_shorts = vim.fn.getenv('ME_SHORTS')
    if is_shorts == 'true' then
        return true
    else
        return false
    end
end

M.maybe_toggle_shorts_mode = function()
    if M.is_shorts_mode() then
        vim.cmd([[ LspStop ]])
        require('cmp').setup.buffer({ enabled = false })
    end
end

M.cycle_notes = function(direction)
    local idx
    local buf_dir = vim.fn.expand('%:p:h')
    local f_name = vim.fn.expand('%:t')
    local files = scandir(buf_dir)

    files = vim.tbl_filter(function(path)
        if path == '.' or path == '..' then
            return false
        end
        return true
    end, files)

    for i, f in ipairs(files) do
        if f == f_name then
            idx = i
        end
    end
    local next_f
    if direction == 'up' then
        next_f = files[idx + 1]
    elseif direction == 'down' then
        next_f = files[idx - 1]
    else
        print('Unknown direction')
    end

    if next_f == nil then
        print('You reached the last note.')
        return
    end

    local cbuf = vim.api.nvim_get_current_buf()
    vim.api.nvim_command('edit ' .. buf_dir .. '/' .. next_f)

    -- Don't delete buffer if it has unsaved changes.
    if vim.api.nvim_buf_get_option(cbuf, 'modified') then
        return
    end

    vim.api.nvim_buf_delete(cbuf, { force = false })
end

local function parse_anki_note_id(str)
    local pattern = '%d%d%d%d%d%d%d%d%d%d%d%d%d'
    local number = string.match(str, pattern)

    if number then
        return tonumber(number)
    else
        return nil
    end
end

M.anki_edit_note = function()
    -- Open a tmux popup running apy in order to review a note.
    local filename = vim.fn.expand('%:t')
    local note_id = parse_anki_note_id(filename)
    if note_id then
        local apy_cmd = '"apy review nid:' .. note_id .. '"'
        local bash_cmd = 'tmux display-popup -h 90% -w 90% -E ' .. apy_cmd
        os.execute(bash_cmd)
    else
        print(filename)
        print('No 13-digit number found.')
    end
end

local function load_json_file(path)
    local file = io.open(path, 'r')
    if not file then
        print('Error opening file at', path)
        return nil
    end
    local content = file:read('*all')
    local json = vim.json.decode(content)
    file:close()
    return json
end

M.find_anki_notes = function(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = 'Anki Notes',
            finder = finders.new_table({
                results = (function()
                    local notes_index = load_json_file(
                        '/home/denis/Sync/notes/current/anki/index.json'
                    )
                    local notes = {}
                    for _, note in ipairs(notes_index.notes) do
                        if not note.is_code_only then
                            table.insert(notes, note)
                        end
                    end
                    return notes
                end)(),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.title,
                        ordinal = entry.title,
                        filename = entry.file_path,
                    }
                end,
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.cmd('e ' .. selection.value.file_path)
                end)
                return true
            end,
        })
        :find()
end

M.slugify = function(text)
    if not text then
        return ''
    end

    local function trim(s)
        return s:match('^%s*(.-)%s*$')
    end

    local slug = text
    -- Remove Markdown headers
    slug = slug:gsub('#', '')
    slug = trim(slug)
    slug = slug:gsub('[^%w%s%-]', '') -- Remove special characters except spaces and hyphens
    slug = slug:gsub('%s+', '-') -- Replace one or more spaces with a single hyphen
    slug = slug:gsub('%-+', '-') -- Replace multiple hyphens with a single hyphen
    return slug:lower()
end

-- local slugify = M.slugify
-- -- Test case 1: Basic text
-- assert(slugify("Hello World") == "hello-world", "Test case 1 failed")
-- -- Test case 2: Text with numbers
-- assert(slugify("Lua 2024 version") == "lua-2024-version", "Test case 2 failed")
-- -- Test case 3: Text with special characters
-- assert(slugify("Special@#Characters!") == "specialcharacters", "Test case 3 failed")
-- -- Test case 4: Text with leading and trailing spaces
-- assert(slugify("  Space around  ") == "space-around", "Test case 4 failed")
-- -- Test case 5: Text with multiple consecutive spaces
-- assert(slugify("Multiple   spaces") == "multiple-spaces", "Test case 5 failed")
-- -- Test case 6: Empty string
-- assert(slugify("") == "", "Test case 6 failed")
-- -- Test case 7: Text with only special characters
-- assert(slugify("@#$%^&*()") == "", "Test case 7 failed")
-- -- Test case 8: Text with mixed case
-- assert(slugify("Mixed CASE text") == "mixed-case-text", "Test case 8 failed")
-- -- Test case 9: Numeric only string
-- assert(slugify("12345") == "12345", "Test case 9 failed")
-- -- Test case 10: String with hyphens
-- assert(slugify("Already-Has-Hyphens") == "already-has-hyphens", "Test case 10 failed")
-- print("All test cases passed!")

M.python_test_file = function()
    -- Get relative path of the current file
    local current_file_path = vim.fn.expand('%:p')
    -- Find the Python project folder by:
    --  - splitting the file path on `/`
    --  - finding the position of `src`
    --  - the project folder is the right above `src`.
    -- Then remove from the path everything that's before the file path
    local parts = vim.fn.split(current_file_path, '/')
    local src_index = vim.fn.index(parts, 'src')
    if src_index == -1 then
        print('Error: \'src\' directory not found in the file path.')
        return
    end
    local project_path = '/' .. table.concat(parts, '/', 1, src_index)

    local fpath = string.gsub(current_file_path, project_path, '')
    parts = vim.fn.split(fpath, '/')
    table.remove(parts, 1) -- remove src
    table.remove(parts, 1) -- remove pkg_name

    parts[#parts] = string.gsub(parts[#parts], '.py', '_test.py')

    -- create directory structure if it doesn't exist
    local test_file_path = project_path .. '/src/tests'
    for i = 1, #parts - 1 do
        test_file_path = test_file_path .. '/' .. parts[i]
        vim.fn.mkdir(test_file_path, 'p')
    end
    test_file_path = test_file_path .. '/' .. parts[#parts]
    vim.cmd('edit ' .. test_file_path)
end

M.copy_file_path_to_clipboard = function()
    local cfile = vim.api.nvim_buf_get_name(0)
    local relative_path = vim.fn.fnamemodify(cfile, ':.')
    local path_parts = vim.split(relative_path, '/')

    -- To locate the project path, either find `src` or `tests`.
    -- The project directory must be the one above.
    local src_index = vim.fn.index(path_parts, 'src')

    local result
    if src_index ~= -1 and src_index > 1 then
        result = table.concat(path_parts, '/', src_index + 1)
    else
        result = relative_path
    end

    vim.fn.setreg('+', result)
    print('Copying to clipboard: ' .. result)
    return result
end

local function sort_markdown_list()
    local ts_utils = require('nvim-treesitter.ts_utils')
    local query = vim.treesitter.query.parse(
        'markdown',
        [[
    (list) @list
  ]]
    )

    local bufnr = vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(bufnr, 'markdown')
    local tree = parser:parse()[1]
    local root = tree:root()

    local function get_list_item_text(node)
        local start_row, start_col, end_row, end_col = node:range()
        local lines =
            vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
        local text = table.concat(lines, '\n')
        return text:match('%-%s*(.+)')
    end

    local function sort_list(list_node)
        local items = {}
        print(vim.inspect(list_node))
        for child in list_node:iter_children() do
            if child:type() == 'list_item' then
                local item_text = get_list_item_text(child)
                local nested_list = child:child(1)
                        and child:child(1):type() == 'list'
                        and child:child(1)
                    or nil
                table.insert(items, {
                    node = child,
                    text = item_text,
                    nested_list = nested_list,
                })
            end
        end

        table.sort(items, function(a, b)
            return a.text:lower() < b.text:lower()
        end)

        local start_row, start_col, end_row, end_col = list_node:range()
        local sorted_text = {}
        for _, item in ipairs(items) do
            local item_start, _, item_end, _ = item.node:range()
            local item_lines = vim.api.nvim_buf_get_lines(
                bufnr,
                item_start,
                item_end + 1,
                false
            )
            for _, line in ipairs(item_lines) do
                table.insert(sorted_text, line)
            end
            if item.nested_list then
                sort_list(item.nested_list)
            end
        end

        vim.api.nvim_buf_set_lines(
            bufnr,
            start_row,
            end_row + 1,
            false,
            sorted_text
        )
    end

    for _, match in query:iter_matches(root, bufnr) do
        print(vim.inspect(match))
        for id, node in pairs(match) do
            if query.captures[id] == 'list' then
                sort_list(node)
            end
        end
    end
end

-- Create a command to call the function
vim.api.nvim_create_user_command('SortMarkdownList', sort_markdown_list, {})

return M
