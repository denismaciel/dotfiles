local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

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
  vim.api.nvim_set_hl(0, '@markup.heading.1', { fg = '#50fa7b' })
  vim.api.nvim_set_hl(0, '@markup.heading.2', { fg = '#ff79c6' })
  vim.api.nvim_set_hl(0, '@markup.heading.3', { fg = '#ffb86c' })
  vim.api.nvim_set_hl(0, '@markup.heading.4', { fg = '#8be9fd' })
  vim.api.nvim_set_hl(0, '@markup.heading.5', { fg = '#f1fa8c' })
end

M.center_and_change_colorscheme = function()
  vim.cmd([[ normal Gzz ]])
  vim.cmd([[ colorscheme no-clown-fiesta ]])
  vim.cmd([[ ZenMode ]])
  M.highlight_markdown_titles()
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
    error('could not find file')
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
              '/home/denis/Sync/Notes/Current/Anki/index.json'
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
  local function ltrim(s)
    return s:match('^%s*(.*)')
  end

  local function rtrim(s)
    return s:match('^(.*%S)%s*$')
  end

  local function trim(s)
    return ltrim(rtrim(s))
  end
  local slug = text
  -- Remove Markdown headers
  slug = slug:gsub('#', '')
  slug = trim(slug)
  slug = slug:gsub('%s', '-')
  slug = slug:gsub('[^%w%-]', '')
  return slug:lower()
end

-- local slugify = M.slugify
--
-- -- Test case 1: Basic text
-- print(slugify("Hello World"))
-- assert(slugify("Hello World") == "hello-world", "Test case 1 failed")
--
-- -- Test case 2: Text with numbers
-- assert(slugify("Lua 2024 version") == "lua-2024-version", "Test case 2 failed")
--
-- -- Test case 3: Text with special characters
-- assert(slugify("Special@#Characters!") == "specialcharacters", "Test case 3 failed")
--
-- -- Test case 4: Text with leading and trailing spaces
-- print(slugify("  Space around  "))
-- assert(slugify("  Space around  ") == "space-around", "Test case 4 failed")
--
-- -- Test case 5: Text with multiple consecutive spaces
-- assert(slugify("Multiple   spaces") == "multiple-spaces", "Test case 5 failed")
--
-- -- Test case 6: Empty string
-- assert(slugify("") == "", "Test case 6 failed")
--
-- -- Test case 7: Text with only special characters
-- assert(slugify("@#$%^&*()") == "", "Test case 7 failed")
--
-- -- Test case 8: Text with mixed case
-- assert(slugify("Mixed CASE text") == "mixed-case-text", "Test case 8 failed")
--
-- -- Test case 9: Numeric only string
-- assert(slugify("12345") == "12345", "Test case 9 failed")
--
-- -- Test case 10: String with hyphens
-- assert(slugify("Already-Has-Hyphens") == "already-has-hyphens", "Test case 10 failed")
--
-- print("All test cases passed!")

return M
