vim.g.mapleader = ' '

---@class vim.opt
local o = vim.opt

o.signcolumn = 'yes'
o.clipboard = 'unnamedplus'
o.formatoptions = o.formatoptions + 'cro'
o.mouse = 'a'
o.tabstop = 4 -- how many spaces a tab is when vim reads a file
o.softtabstop = 4 --how many spaces are inserted when you hit tab
o.shiftwidth = 4
o.autoindent = true
o.expandtab = true
o.hidden = true -- switch buffers without saving
o.wrap = false
o.number = false
o.termguicolors = true
o.backspace = { 'indent', 'eol', 'start' }
o.showcmd = false -- show command in bottom bar
o.showmatch = true -- highlight matching parenthesis

o.backup = false
o.swapfile = false

-- Search
o.incsearch = true -- search as characters are entered
o.hlsearch = true -- highlight matches
o.ignorecase = true
o.smartcase = true
o.scrolloff = 10 -- keep X lines above and below the cusrsor when scrolling

-- o.cursorline = true
-- o.cursorlineopt = 'number'

o.undodir = os.getenv('HOME') .. '/.config/nvim/undodir'

-- Decrease update time
o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
o.timeoutlen = 300

o.list = true
o.listchars = {
    tab = '▸ ',
    trail = '·',
    nbsp = '␣',
    extends = '❯',
    precedes = '❮',
}
o.fillchars = { eob = ' ' } -- hide ~ at end of buffer

o.undofile = true

o.splitbelow = true
o.splitright = true

o.completeopt = { 'menu', 'menuone', 'noselect' }

-- o.laststatus = 0
-- o.cmdheight =
o.showmode = true
o.ruler = false

if os.getenv('MODE') == 'notebook' then
    vim.keymap.set('n', '<c-j>', ':tabnext<cr>')
    vim.keymap.set('n', '<c-k>', ':tabprev<cr>')
end

-- Theme detection and switching
local function get_system_theme()
    local theme_file = os.getenv('HOME') .. '/.config/dennich-colorscheme'
    local file = io.open(theme_file, 'r')
    if file then
        local theme = file:read('*line')
        file:close()
        return theme and theme:match('^%s*(.-)%s*$') or 'light'
    end
    return 'light'
end

local function apply_theme()
    local theme = get_system_theme()
    if theme == 'dark' then
        -- vim.cmd([[ colorscheme no-clown-fiesta ]])
        vim.cmd([[ colorscheme gruvbox ]])
    else
        vim.cmd([[ colorscheme catppuccin-latte ]])
    end
end

-- Apply theme on startup
apply_theme()

-- Add manual toggle command
vim.api.nvim_create_user_command('ToggleTheme', function()
    local current = get_system_theme()
    local new_theme = current == 'light' and 'dark' or 'light'

    -- Write new preference
    local theme_file = os.getenv('HOME') .. '/dotfiles/theme-preference'
    local file = io.open(theme_file, 'w')
    if file then
        file:write(new_theme)
        file:close()
    end

    -- Apply immediately
    apply_theme()
    print('Switched to ' .. new_theme .. ' theme')
end, {})

-- Respect terminal cursor - let tmux handle cursor styling
vim.opt.guicursor = ''

vim.cmd('cabbrev W w')
vim.cmd('cabbrev Wq wq')
vim.cmd('cabbrev WQ wq')

vim.cmd('command! Bd bp | sp | bn | bd')
vim.cmd('command! Bdd bp! | sp! | bn! | bd!')
vim.cmd('cabbrev bd Bd')
vim.cmd('cabbrev bd! Bdd')
vim.cmd('cabbrev Bd! Bdd')

vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    float = { border = 'rounded' },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '✗',
            [vim.diagnostic.severity.WARN] = '▲',
            [vim.diagnostic.severity.HINT] = '◇',
            [vim.diagnostic.severity.INFO] = '◆',
            ['DapBreakpoint'] = '●',
        },
    },
})

-- Colorized diagnostic sign highlights
vim.api.nvim_set_hl(0, 'DiagnosticSignError', { fg = '#ff6c6b', bold = true })
vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = '#da8548', bold = true })
vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { fg = '#4db5bd', bold = true })
vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { fg = '#98be65', bold = true })

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 400 })
    end,
})

vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('CustomizeWebDev', { clear = true }),
    pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('CustomizeNix', { clear = true }),
    pattern = { '*.nix' },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup('CustomizeEnv', { clear = true }),
    pattern = { '.env.*', '*.env' },
    callback = function()
        vim.bo.filetype = 'sh'
        -- Detach bashls clients by name instead of hard-coding client ID
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
            if client.name == 'bashls' then
                vim.lsp.buf_detach_client(0, client.id)
            end
        end
    end,
})

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        local file_path = vim.fn.expand('%:p')
        if file_path == '/tmp/tmux_pane_content' then
            -- vim.cmd('colorscheme tokyonight')
        end
    end,
})

local dennich = require('dennich')

-- Keymaps
vim.keymap.set({ 'n' }, '<leader>is', dennich.create_python_import_symbol)
vim.keymap.set({ 'n' }, '<leader>if', function()
    require('telescope.builtin').find_files({
        attach_mappings = function(_, map)
            map('i', '<cr>', dennich.create_python_import_file)
            return true
        end,
    })
end, { desc = 'Python import statement' })

vim.keymap.set('n', '<leader>xl', ':.lua<cr>')
vim.keymap.set('v', '<leader>xl', ':lua<cr>')

vim.keymap.set('n', '<leader>;', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeFindFileToggle<CR>')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '$', 'g$')
vim.keymap.set('n', '<c>o', '<c>ozz')
vim.keymap.set('n', '<c>]', '<c>]zz')
vim.keymap.set('n', '0', 'g0')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'gp', '`[v`]')
vim.keymap.set('x', 'p', 'pgvy') -- https://stackoverflow.com/questions/290465/how-to-paste-over-without-overwriting-register
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '//', [[ y/\V<C-R>=escape(@",'/\')<CR><CR> ]]) --- Search currenlty selected text

vim.keymap.set(
    'n',
    '<leader>fc',
    require('dennich').copy_file_path_to_clipboard,
    { desc = 'Copy file path to clipboard' }
)
vim.keymap.set(
    'n',
    '<leader>fl',
    require('dennich').copy_file_path_with_line_to_clipboard,
    { desc = 'Copy file path with line number to clipboard' }
)
vim.keymap.set('n', '<leader>ff', function()
    vim.lsp.buf.format()
    require('conform').format()
end, { desc = 'Format current buffer' })
-- Built-in replacements for Trouble.nvim
local function _is_loclist_open()
    return vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
end
local function _is_qflist_open()
    return vim.fn.getqflist({ winid = 0 }).winid ~= 0
end
local function _open_loclist_keep_focus()
    local cur = vim.api.nvim_get_current_win()
    vim.cmd('lopen')
    if vim.api.nvim_get_current_win() ~= cur then
        vim.cmd('wincmd p')
    end
end

local function toggle_file_diagnostics_loclist()
    if _is_loclist_open() then
        vim.cmd('lclose')
    else
        -- Populate current window's location list with buffer diagnostics
        vim.diagnostic.setloclist({ open = false })
        _open_loclist_keep_focus()
    end
end

local function toggle_workspace_diagnostics_qflist()
    if _is_qflist_open() then
        vim.cmd('cclose')
    else
        -- Populate quickfix with diagnostics from all buffers
        local cur = vim.api.nvim_get_current_win()
        vim.diagnostic.setqflist({ open = true })
        -- Return focus to the previous window
        if vim.api.nvim_get_current_win() ~= cur then
            vim.cmd('wincmd p')
        end
    end
end

local function _populate_symbols_loclist_and_open()
    local bufnr = vim.api.nvim_get_current_buf()
    local params = { textDocument = vim.lsp.util.make_text_document_params() }
    vim.lsp.buf_request(
        bufnr,
        'textDocument/documentSymbol',
        params,
        function(err, result)
            if err then
                vim.notify(
                    'LSP symbols error: ' .. (err.message or ''),
                    vim.log.levels.ERROR
                )
                return
            end
            if not result or vim.tbl_isempty(result) then
                vim.notify('No symbols from LSP', vim.log.levels.INFO)
                return
            end
            local items = vim.lsp.util.symbols_to_items(result, bufnr) or {}
            if vim.tbl_isempty(items) then
                vim.notify('No symbols found', vim.log.levels.INFO)
                return
            end
            vim.fn.setloclist(
                0,
                {},
                ' ',
                { title = 'Document Symbols', items = items }
            )
            _open_loclist_keep_focus()
        end
    )
end

local function toggle_symbols_loclist()
    if _is_loclist_open() then
        vim.cmd('lclose')
    else
        _populate_symbols_loclist_and_open()
    end
end

vim.keymap.set('n', '<leader>xx', toggle_file_diagnostics_loclist, {
    desc = 'File Diagnostics (loclist)',
})
vim.keymap.set('n', '<leader>xa', toggle_workspace_diagnostics_qflist, {
    desc = 'Workspace Diagnostics (quickfix)',
})
vim.keymap.set(
    'n',
    '<leader>xk',
    vim.diagnostic.open_float,
    { desc = 'Line Diagnostics (floating)' }
)

vim.keymap.set('n', '<leader>cs', toggle_symbols_loclist, {
    desc = 'Document Symbols (loclist)',
})

vim.keymap.set(
    'n',
    '<leader>tss',
    [["=strftime('%Y-%m-%d %H:%M')<CR>pI### <Esc>o<Enter>]],
    { desc = 'Insert current timestamp' }
)
vim.keymap.set(
    'n',
    '<leader>tsd',
    [["=strftime('%Y-%m-%d (%a)')<CR>p]],
    { desc = 'Insert current time' }
)
vim.keymap.set(
    'n',
    '<leader>u',
    '<cmd>UndotreeToggle<CR>',
    { desc = 'Undotree' }
)

vim.keymap.set({ 'n' }, '<leader>ao', function()
    dennich.find_anki_notes(require('telescope.themes').get_dropdown({}))
end, {
    desc = '[anki] find note',
})

vim.keymap.set({ 'n' }, '<leader>ae', function()
    dennich.anki_edit_note()
end, {
    desc = '[anki] edit note',
})

vim.keymap.set('n', 'tt', function()
    require('fzf-lua').files({
        actions = {
            ['ctrl-y'] = dennich.fzf_lua_insert_relative_file_path,
        },
        cmd = 'rg --files --hidden '
            .. '--glob "!.git" '
            .. '--glob "!*.png" '
            .. '--glob "!*.xlsx" '
            .. '--glob "!.snapshots/" '
            .. '--glob "!*.xsd" '
            .. '--glob "!*.jpeg" '
            .. '--glob "!*.jpg" '
            .. '--glob "!*.webp" '
            .. '--glob "!**/test_data/**/*.json" '
            .. '--glob "!**/test_data/**/*.jsonl" '
            .. '--glob "!**/testdata/**/*.json" '
            .. '--glob "!**/testdata/**/*.jsonl"',
        -- You can add any fzf-lua specific options here, for example:
        -- previewer = true,
        -- prompt = "Files> ",
    })
end, { desc = '[T]elescope Find Files' })
vim.keymap.set(
    'n',
    'td',
    dennich.insert_text,
    { desc = 'Insert block of text' }
)
vim.keymap.set(
    'n',
    'tc',
    require('telescope.builtin').commands,
    { desc = '[T]elescope Vim [C]ommands' }
)
vim.keymap.set(
    'n',
    'tch',
    require('telescope.builtin').command_history,
    { desc = '[T]elescope Vim [C]ommand [H]istory' }
)
vim.keymap.set(
    'n',
    'the',
    require('telescope.builtin').help_tags,
    { desc = '[T]elescope Vim [H][e]lp' }
)
vim.keymap.set(
    'n',
    'tft',
    require('telescope.builtin').filetypes,
    { desc = '[T]elescope [F]ile[T]ypes' }
)
vim.keymap.set(
    'n',
    'tm',
    require('telescope.builtin').marks,
    { desc = '[T]elescope [M]arks' }
)
vim.keymap.set(
    'n',
    'tb',
    require('telescope.builtin').current_buffer_fuzzy_find,
    { desc = '[T]elescope [B]uffers' }
)
vim.keymap.set(
    'n',
    '<leader>rg',
    -- require('telescope').extensions.egrepify.egrepify
    require('fzf-lua').live_grep
)
vim.keymap.set('n', '<leader>/', require('telescope.builtin').treesitter)

vim.keymap.set('n', '<leader>o', function()
    local config_file = os.getenv('HOME') .. '/.config/nvim/lua/init.lua'
    vim.cmd('edit' .. config_file)
end)

local function open_test_file_go()
    local current_file_path = vim.fn.expand('%:p')
    current_file_path = string.gsub(current_file_path, vim.fn.getcwd(), '')
    local parts = vim.fn.split(current_file_path, '/')
    parts[#parts] = string.gsub(parts[#parts], '.go', '_test.go')

    local test_file_path = '.'
    for i = 1, #parts do
        test_file_path = test_file_path .. '/' .. parts[i]
    end

    vim.cmd('edit ' .. test_file_path)
end

local function open_test_file()
    local ft = vim.bo.filetype
    if ft == 'go' then
        open_test_file_go()
    elseif ft == 'python' then
        require('dennich').python_test_file()
    else
        print('No implementation for filetype: ' .. ft)
    end
end

vim.keymap.set('n', '<leader>ro', open_test_file)

vim.keymap.set('n', '<leader>gn', function()
    local HOME = os.getenv('HOME') .. '/'
    local NOTES_FOLDER = HOME .. 'Sync/notes'
    local PARROT_FOLDER = HOME .. '.local/share/nvim/parrot/chats/'
    local bufnr = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    local cwd = vim.fn.getcwd()

    if true then
        vim.cmd([[ LLM ]])
        return
    end

    -- If cwd is not notes folder, run LLM command
    print(cwd)
    if not vim.startswith(cwd, NOTES_FOLDER) then
        vim.cmd([[ LLM ]])
        return
    end

    -- If the current buffer is a chat, open a new blank chat.
    if vim.startswith(buf_name, PARROT_FOLDER) then
        vim.cmd([[PrtChatNew]])
        return
    end

    local parrot_buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if
            vim.startswith(name, PARROT_FOLDER)
            and vim.api.nvim_buf_is_loaded(buf)
        then
            table.insert(parrot_buffers, name)
        end
    end

    -- If there are already open parrot buffers, and we're not in one alread,
    -- focus on the latest one.
    if #parrot_buffers > 0 then
        table.sort(parrot_buffers)
        vim.cmd(
            'buffer ' .. vim.fn.fnameescape(parrot_buffers[#parrot_buffers])
        )
    else
        -- If there are no parrot buffers, create one.
        vim.cmd([[ PrtChatNew ]])
    end
end)

vim.keymap.set('n', '<leader>gt', function()
    require('dennich').open_todo_note()
end)

vim.keymap.set('n', '<leader>gs', function()
    local branch = vim.fn
        .system('git rev-parse --abbrev-ref HEAD 2>/dev/null')
        :gsub('\n', '')

    if vim.v.shell_error == 0 and branch ~= '' then
        -- In a git repo, open track/<branch>.md
        local track_dir = './track'
        vim.fn.mkdir(track_dir, 'p')
        local safe_branch = branch:gsub('/', '-')
        local file_path = track_dir .. '/' .. safe_branch .. '.md'
        vim.cmd('edit ' .. file_path)
    else
        -- Not in a git repo, fallback to original behavior
        local HOME = os.getenv('HOME') .. '/'
        local cwd = vim.fn.getcwd()

        if vim.startswith(cwd, HOME .. 'Sync/notes') then
            require('dennich').create_weekly_note()
        else
            require('dennich').open_track_md()
        end
    end
    vim.cmd('normal! G') -- Go to the end of the file
end)

vim.keymap.set('n', '<leader>rr', function()
    package.loaded['dennich'] = nil
    require('dennich').run()
end)

-- Theme toggle keymap
vim.keymap.set(
    'n',
    '<leader>tt',
    '<cmd>ToggleTheme<cr>',
    { desc = 'Toggle theme' }
)
