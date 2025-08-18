local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

local HOME = os.getenv('HOME') .. '/'
local NOTES_FOLDER = HOME .. 'Sync/notes/'

M.is_url = function(text)
    if text == nil then
        return false
    end
    local url_pattern = '^https?://[%w-_%.%?%.:/%+=&;,@]+$'
    return string.match(text, url_pattern) ~= nil
end

M.create_weekly_note = function()
    -- Get current date information
    local current_time = os.time()
    local date_table = os.date('*t', current_time)

    -- Calculate the Monday of current week
    -- TODO: this is not Monday, but rather Sunday
    local days_since_monday = (date_table.wday + 6) % 7 -- Convert to Monday=0, Sunday=6
    local monday_timestamp = current_time - (days_since_monday * 24 * 60 * 60)
    local monday_date = os.date('%Y-%m-%d', monday_timestamp)

    local target_folder = NOTES_FOLDER .. 'current/private'

    local file_path_week = target_folder .. '/weekly/' .. monday_date .. '.md'

    -- Change to notes folder
    vim.fn.chdir(NOTES_FOLDER)

    -- Check if file exists, if not create it with header
    local file = io.open(file_path_week, 'r')
    if not file then
        file = io.open(file_path_week, 'w')
        if file then
            file:write('# ' .. monday_date)
            file:close()
        end
    else
        file:close()
    end

    -- Create daily note path and file
    local today_date = os.date('%Y-%m-%d', current_time)
    local file_path_day = target_folder .. '/daily/' .. today_date .. '.md'

    -- Check if daily file exists, if not create it with header
    local file_day = io.open(file_path_day, 'r')
    if not file_day then
        file_day = io.open(file_path_day, 'w')
        if file_day then
            file_day:write(
                '# ' .. today_date .. ' (' .. os.date('%A', current_time) .. ')'
            )
            file_day:close()
        end
    else
        file_day:close()
    end

    vim.cmd('edit ' .. vim.fn.fnameescape(file_path_day))
end

M.open_todo_note = function()
    vim.fn.chdir(NOTES_FOLDER)
    vim.cmd('edit todo.md')
end

local function scandir(directory)
    local i, t = 0, {}
    -- Use ls -p to append / to directories, then grep to exclude them
    local pfile = io.popen('ls -ap "' .. directory .. '" | grep -v "/$"')

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

---@alias RoutineItem { text: string, condition: function }
---@return string[]
local routine = function()
    local always = function()
        return true
    end

    local is_weekday = function()
        -- return false
        local day = os.date('*t').wday
        return day >= 2 and day <= 6
    end

    -- Define items with their conditions
    ---@type RoutineItem[]
    local items = {
        { text = '- [ ] #routine Anki', condition = always },
        -- { text = '- [ ] #routine Gather', condition = always },
        { text = '- [ ] #routine Creatina', condition = always },
        { text = '- [ ] #routine #home Inbox Zero', condition = always },
        { text = '- [ ] #routine Clean up for 5 min', condition = always },
        { text = '- [ ] #routine Chores for 10 min', condition = always },
        { text = '- [ ] #routine Curate todo list', condition = always },
        { text = '- [ ] #routine Check Kinderpedia', condition = is_weekday },
        { text = '- [ ] #routine 15 push-ups', condition = always },
        { text = '- [ ] #routine 10 pull-ups', condition = always },
        { text = '- [ ] #routine #recap Notion BOD', condition = is_weekday },
        { text = '- [ ] #routine #recap Inbox Zero', condition = is_weekday },
        { text = '- [ ] #routine Plan the day', condition = always },
        { text = '- [ ] #routine Magnésio', condition = always },
    }

    -- Filter items based on their conditions and extract text
    local result = {}
    for _, item in ipairs(items) do
        if item.condition() then
            table.insert(result, item.text)
        end
    end

    return result
end

local function load_prompt_files()
    local prompts_dir = vim.fn.stdpath('config') .. '/prompts'
    local prompt_files = vim.fn.glob(prompts_dir .. '/*.md', false, true)
    local results = {}

    -- Add routine as inline content
    table.insert(results, {
        title = 'Routine',
        content = routine(),
    })

    -- Add file-based prompts
    for _, file_path in ipairs(prompt_files) do
        local filename = vim.fn.fnamemodify(file_path, ':t:r') -- basename without .md
        table.insert(results, {
            title = filename,
            file_path = file_path,
        })
    end

    return results
end

local function read_file_content(file_path)
    local file = io.open(file_path, 'r')
    if not file then
        return 'Error: Could not read file ' .. file_path
    end
    local content = file:read('*all')
    file:close()
    return content
end

M.insert_text = function(opts)
    local cb = vim.api.nvim_get_current_buf()
    local cline = vim.api.nvim_win_get_cursor(0)[1]
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = 'Insert Block',
            finder = finders.new_table({
                results = load_prompt_files(),
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
                    local content

                    if selection.value.content then
                        -- Inline content (like Routine)
                        content = selection.value.content
                    elseif selection.value.file_path then
                        -- File-based content
                        content = read_file_content(selection.value.file_path)
                    else
                        content = 'Error: No content or file_path found'
                    end

                    vim.api.nvim_buf_set_lines(
                        cb,
                        cline,
                        cline,
                        false,
                        type(content) == 'string' and vim.split(content, '\n')
                            or content
                    )
                end)
                return true
            end,
        })
        :find()
end

M.center_and_change_colorscheme = function()
    vim.cmd([[ normal Gzz ]])
end

M.cycle_notes = function(direction)
    local buf_dir = vim.fn.expand('%:p:h')
    local f_name = vim.fn.expand('%:t')
    local files = scandir(buf_dir)

    files = vim.tbl_filter(function(path)
        if path == '.' or path == '..' then
            return false
        end
        return true
    end, files)

    local idx
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
    local determine_file_path = function()
        local cfile = vim.api.nvim_buf_get_name(0)
        local relative_path = vim.fn.fnamemodify(cfile, ':.')

        if vim.bo.filetype ~= 'python' then
            return relative_path
        end

        local path_parts = vim.split(relative_path, '/')
        local src_index = vim.fn.index(path_parts, 'src')

        -- If `src` is not found, we return the relative path as is.
        if src_index == -1 then
            return relative_path
        end
        -- If `src` is the first part, we are already at the root of the project.
        if src_index == 0 then
            return relative_path
        end

        -- If `src` is found, we remove everything before it.
        return table.concat(path_parts, '/', src_index + 1)
    end

    local result = determine_file_path()
    vim.fn.setreg('+', result)
    print('Copying to clipboard: ' .. result)
    return result
end

M.copy_full_file_path_to_clipboard = function()
    local cfile = vim.api.nvim_buf_get_name(0)
    local full_path = vim.fn.fnamemodify(cfile, ':p')
    vim.fn.setreg('+', full_path)
    print('Copying to clipboard: ' .. full_path)
    return full_path
end

M.copy_file_path_with_line_to_clipboard = function()
    local determine_file_path = function()
        local cfile = vim.api.nvim_buf_get_name(0)
        local relative_path = vim.fn.fnamemodify(cfile, ':.')

        if vim.bo.filetype ~= 'python' then
            return relative_path
        end

        local path_parts = vim.split(relative_path, '/')
        local src_index = vim.fn.index(path_parts, 'src')

        -- If `src` is not found, we return the relative path as is.
        if src_index == -1 then
            return relative_path
        end
        -- If `src` is the first part, we are already at the root of the project.
        if src_index == 0 then
            return relative_path
        end

        -- If `src` is found, we remove everything before it.
        return table.concat(path_parts, '/', src_index + 1)
    end

    local file_path = determine_file_path()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local result = file_path .. ':' .. line_num
    vim.fn.setreg('+', result)
    print('Copying to clipboard: ' .. result)
    return result
end

local function sort_markdown_list()
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

M.telescope_insert_relative_file_path = function(selected)
    local selection = selected[1]
    if selection then
        local full_path = selection.value
        if selection.path then
            full_path = selection.path
        end
        -- Convert to relative path
        local relative_path = vim.fn.fnamemodify(full_path, ':.')

        -- Now get current buffer and cursor position after closing telescope
        local current_buf = vim.api.nvim_get_current_win()
        local cursor_pos = vim.api.nvim_win_get_cursor(current_buf)
        local row, col = cursor_pos[1], cursor_pos[2]

        -- Insert the path with @ prefix at cursor position
        local text_to_insert = '@' .. relative_path
        vim.api.nvim_buf_set_text(
            0,
            row - 1,
            col,
            row - 1,
            col,
            { text_to_insert }
        )

        -- Notify user
        print('Inserted: ' .. text_to_insert)
    end
end

M.fzf_lua_insert_relative_file_path = function(selected)
    local selection = selected[1]

    if selection == nil then
        print('No selection made.')
        return
    end

    -- We need to remove the filetype utf-8 symbols from the selection
    -- 1. Split the selection by `/`. The symbols are always at the beginning.
    -- 2. Remove non-alphanumeric characters from the first part.
    -- 3. Join the parts back together.
    local parts = vim.split(selection, '/')
    local first_part = parts[1]
    local ascii_only = first_part:gsub('[^%w%s%.%-]', '')
    parts[1] = ascii_only
    local relative_path = table.concat(parts, '/')

    -- Ready to write it back to the current buffer.
    local current_buf = vim.api.nvim_get_current_win()
    local cursor_pos = vim.api.nvim_win_get_cursor(current_buf)
    local row, col = cursor_pos[1], cursor_pos[2]

    local text_to_insert = '@' .. relative_path
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { text_to_insert })
    -- Notify user
    print('Inserted: ' .. text_to_insert)
end

local get_track_md_path = function()
    local is_git_repo =
        vim.fn.systemlist('git rev-parse --is-inside-work-tree')[1]

    if is_git_repo ~= 'true' then
        print('Not inside a Git repository.')
        return nil
    end

    local root_dir = vim.fn.systemlist('git rev-parse --show-toplevel')[1]

    if not root_dir or root_dir == '' then
        print('Could not determine Git repository root.')
        return nil
    end

    -- For some repos, I don't or can't commit the track.md file.
    -- In those cases, I name the file track-{git-repo-name}.md
    -- and add it in the global gitignore.
    local repo_name = vim.fn.fnamemodify(root_dir, ':t')
    local track_file = root_dir .. '/track-' .. repo_name .. '.md'
    if vim.fn.filereadable(track_file) == 1 then
        return track_file
    end

    -- Path to the track.md inside the repo root
    return root_dir .. '/track.md'
end

M.open_track_md = function()
    local track_md_path = get_track_md_path()
    if not track_md_path then
        return
    end

    -- Check if the track file is already open in any window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name == track_md_path then
            -- File is already open, close the window
            vim.api.nvim_win_close(win, false)
            return
        end
    end

    -- File is not open, open it
    vim.api.nvim_command('leftabove vsplit ' .. track_md_path)
    vim.api.nvim_command('vertical resize 80')
end

M.run = function()
    print('here')
    M.open_track_md()
    print('there')
end

local create_import_from_file_path = function(file_path)
    local parts = vim.fn.split(file_path, '/')
    local src_index = vim.fn.index(parts, 'src')
    if src_index == -1 then
        error('Error: \'src\' directory not found in the file path.')
        return
    end

    -- Find the index of 'src' in the table and remove every element before
    -- 'src' including 'src' itself.
    for i = 1, #parts do
        if parts[i] == 'src' then
            for _ = 1, i do
                table.remove(parts, 1)
            end
            break
        end
    end

    -- remove .py
    parts[#parts] = string.gsub(parts[#parts], '.py', '')

    local import_path = table.concat(parts, '.')
    local statement = string.format('from %s import ', import_path)
    return statement
end

M.create_python_import_symbol = function()
    local current_file = vim.fn.expand('%:p')
    local statement = create_import_from_file_path(current_file)
    local cword = vim.fn.expand('<cword>')
    local out = statement .. cword
    print('Copying to clipboard: ' .. out)
    vim.fn.setreg('+', out)
end

M.create_python_import_file = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection == nil then
        error('No file selected')
        return
    end

    local out = create_import_from_file_path(selection.value)
    vim.fn.setreg('+', out)
    -- Close the Telescope window
    actions.close(prompt_bufnr)
    print('statement avilable in the clipboard: ' .. out)
end

return M
