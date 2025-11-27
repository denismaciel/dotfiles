local M = {}

local HOME = os.getenv('HOME') or ''
local NOTE_ROOT = os.getenv('LLM_NOTE_DIR')
if not NOTE_ROOT or NOTE_ROOT == '' then
    NOTE_ROOT = HOME .. '/Sync/notes/quick'
end

local function ensure_note_dir()
    if vim.fn.isdirectory(NOTE_ROOT) == 0 then
        vim.fn.mkdir(NOTE_ROOT, 'p')
    end
end

local function get_git_origin_name()
    -- Returns normalized repo name from origin URL (git@.../name.git -> name)
    local ok, origin = pcall(function()
        return vim.fn.systemlist('git config --get remote.origin.url')[1] or ''
    end)
    if not ok or not origin or origin == '' then
        return nil
    end

    local name = origin:match('([^/]+)%.git$') or origin:match('([^/]+)$')
    if not name then
        return nil
    end

    name = name:lower()
        :gsub('[^%w-]', '-')
        :gsub('%-+', '-')
        :gsub('^%-', '')
        :gsub('%-$', '')
    if name == '' then
        return nil
    end
    return name
end

function M.get_note_dir()
    return NOTE_ROOT
end

function M.create_timestamped_md()
    ensure_note_dir()

    local timestamp = os.date('%Y-%m-%d_%H-%M-%S')
    local repo = get_git_origin_name()
    local suffix = repo and ('-' .. repo) or ''
    local file_path = string.format('%s/%s%s.md', NOTE_ROOT, timestamp, suffix)

    vim.api.nvim_command('edit ' .. file_path)
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
end

function M.pick_note_files()
    ensure_note_dir()

    local ok, fzf = pcall(require, 'fzf-lua')
    if not ok then
        vim.notify('fzf-lua not available', vim.log.levels.ERROR, {
            title = 'Note picker',
        })
        return
    end

    fzf.files({
        cwd = NOTE_ROOT,
        prompt = 'Notes> ',
        previewer = 'builtin',
        fd_opts = '--type f --color=never --hidden --follow --glob *.md --sort=none',
        fn_transform = function(entries)
            table.sort(entries, function(a, b)
                return a > b
            end)
            return entries
        end,
    })
end

function M.focus_tree_on_note_or_toggle()
    ensure_note_dir()
    local ok, api = pcall(require, 'nvim-tree.api')
    if not ok then
        vim.cmd('NvimTreeFindFileToggle')
        return
    end

    local current = vim.fn.expand('%:p')
    local in_notes = current ~= '' and vim.startswith(current, NOTE_ROOT)

    if in_notes then
        api.tree.open({
            path = NOTE_ROOT,
            focus = true,
            find_file = true,
        })
    else
        api.tree.toggle({ find_file = true, focus = true })
    end
end

function M.setup()
    vim.api.nvim_create_user_command('Note', M.create_timestamped_md, {})
    vim.api.nvim_create_user_command('NotePicker', M.pick_note_files, {})
end

return M
