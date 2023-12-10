local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local M = {}

local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. directory .. '"')

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

M.highlight_markdown_titles = function()
    vim.api.nvim_set_hl(0, '@text.title.1', { fg = '#50fa7b' })
    vim.api.nvim_set_hl(0, '@text.title.2', { fg = '#ff79c6' })
    vim.api.nvim_set_hl(0, '@text.title.3', { fg = '#ffb86c' })
    vim.api.nvim_set_hl(0, '@text.title.4', { fg = '#8be9fd' })
    vim.api.nvim_set_hl(0, '@text.title.5', { fg = '#f1fa8c' })
end

M.center_and_change_colorscheme = function()
    vim.cmd [[ normal Gzz ]]
    vim.cmd [[ colorscheme tokyonight ]]
    vim.cmd [[ ZenMode ]]
    M.highlight_markdown_titles()
end

M.is_shorts_mode = function()
    local is_shorts = vim.fn.getenv 'ME_SHORTS'
    if is_shorts == 'true' then
        return true
    else
        return false
    end
end

M.maybe_toggle_shorts_mode = function()
    if M.is_shorts_mode() then
        vim.cmd [[ LspStop ]]
        require('cmp').setup.buffer { enabled = false }
    end
end

M.cycle_notes = function(direction)
    local idx
    local buf_dir = vim.fn.expand '%:p:h'
    local f_name = vim.fn.expand '%:t'
    local files = scandir(buf_dir)

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
        print 'Unkown direction'
    end

    if next_f == nil then
        error 'could not find file'
    end
    local cbuf = vim.api.nvim_get_current_buf()
    vim.api.nvim_command('edit ' .. buf_dir .. '/' .. next_f)
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

M.edit_anki_note_command = function()
    local filename = vim.fn.expand '%:t'
    local number = parse_anki_note_id(filename)
    if number then
        local bash_cmd = 'apy review nid:' .. number
        local nvim_cmd = 'echo -n "'
            .. bash_cmd
            .. '" | xclip -selection clipboard'
        os.execute(nvim_cmd)
    else
        print 'No 13-digit number found.'
    end
end

local function load_json_file(path)
    local file = io.open(path, 'r')
    if not file then
        print('Error opening file at', path)
        return nil
    end
    local content = file:read '*all'
    local json = vim.json.decode(content)
    file:close()
    return json
end

M.find_anki_notes = function(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = 'Anki Notes',
            finder = finders.new_table {
                results = (function()
                    local notes_index =
                        load_json_file '/home/denis/Sync/Notes/Current/Anki/index.json'
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
                        filename = entry.file_name,
                    }
                end,
            },
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.cmd('e ' .. selection.value.file_name)
                end)
                return true
            end,
        })
        :find()
end

return M
