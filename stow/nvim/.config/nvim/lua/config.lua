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
o.wrap = false

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
o.showmatch = true

o.splitbelow = true
o.splitright = true

o.completeopt = { 'menu', 'menuone', 'noselect' }

-- o.laststatus = 0
-- o.cmdheight =
o.showmode = true
o.ruler = false
o.showcmd = false

if os.getenv('MODE') == 'notebook' then
    vim.keymap.set('n', '<c-j>', ':tabnext<cr>')
    vim.keymap.set('n', '<c-k>', ':tabprev<cr>')
end

-- Theme detection and switching
local function get_system_theme()
    local theme_file = os.getenv('HOME') .. '/dotfiles/theme-preference'
    local file = io.open(theme_file, 'r')
    if file then
        local theme = file:read('*line')
        file:close()
        return theme and theme:match('^%s*(.-)%s*$') or 'light'
    end
    -- Create default file if it doesn't exist
    local default_file = io.open(theme_file, 'w')
    if default_file then
        default_file:write('light')
        default_file:close()
    end
    return 'light'
end

local function apply_theme()
    local theme = get_system_theme()
    if theme == 'dark' then
        vim.cmd([[ colorscheme no-clown-fiesta ]])
    else
        vim.cmd([[ colorscheme lumiere ]])
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
            [vim.diagnostic.severity.ERROR] = '•',
            [vim.diagnostic.severity.WARN] = '•',
            [vim.diagnostic.severity.HINT] = '•',
            [vim.diagnostic.severity.INFO] = '•',
            ['DapBreakpoint'] = '•',
        },
    },
})

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
    pattern = { '*.js', '*.jsx', '*.ts', '*.tsx', '*.html', '*.css', '*.scss' },
    callback = function()
        vim.api.nvim_buf_set_option(0, 'shiftwidth', 4)
    end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup('CustomizeEnv', { clear = true }),
    pattern = { '.env.*', '*.env' },
    callback = function()
        vim.bo.filetype = 'sh'
        vim.lsp.buf_detach_client(0, 1) -- 0: current buffer, 1: bash clients (the only lsp running)
    end,
})

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

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

local create_python_import_symbol = function()
    local current_file = vim.fn.expand('%:p')
    local statement = create_import_from_file_path(current_file)
    local cword = vim.fn.expand('<cword>')
    local out = statement .. cword
    print('Copying to clipboard: ' .. out)
    vim.fn.setreg('+', out)
end

local create_python_import_file = function(prompt_bufnr)
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

-- Keymaps
vim.keymap.set({ 'n' }, '<leader>is', create_python_import_symbol)
vim.keymap.set({ 'n' }, '<leader>if', function()
    require('telescope.builtin').find_files({
        attach_mappings = function(_, map)
            map('i', '<cr>', create_python_import_file)
            return true
        end,
    })
end, { desc = 'Python import statement' })

vim.keymap.set('n', '<leader>xl', ':.lua<cr>')
vim.keymap.set('v', '<leader>xl', ':lua<cr>')

vim.keymap.set('n', '<leader>;', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeFindFileToggle<CR>')

vim.keymap.set('n', 'gtt', function()
    local opts = require('telescope.themes').get_dropdown({
        layout_strategy = 'vertical',
        border = true,
        fname_width = 90,
        layout_config = {
            prompt_position = 'bottom',
            preview_cutoff = 10,
            width = function(_, max_columns, _)
                return max_columns - 10
            end,
            height = function(_, _, max_lines)
                return max_lines - 10
            end,
        },
    })
    opts.ctags_file = vim.fn.getcwd() .. '/tags'
    require('telescope.builtin').tags(opts)
end, { desc = 'Tags' })
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

vim.keymap.set('n', '<leader>ff', function()
    vim.lsp.buf.format()
    require('conform').format()
end, { desc = 'Format current buffer' })
vim.keymap.set(
    'n',
    '<leader>xx',
    '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    { desc = '[Trouble] File Diagnostics' }
)
vim.keymap.set(
    'n',
    '<leader>xa',
    '<cmd>Trouble diagnostics toggle<cr>',
    { desc = '[Trouble] Project Diagnostics' }
)
vim.keymap.set(
    'n',
    '<leader>xk',
    vim.diagnostic.open_float,
    { desc = 'Line Diagnostics (floating)' }
)

vim.keymap.set(
    'n',
    '<leader>cs',
    '<cmd>Trouble symbols toggle focus=false<cr>',
    { desc = 'Symbols (Trouble)' }
)

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

vim.keymap.set('n', 'tt', function()
    require('fzf-lua').files({
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
    require('telescope').extensions.egrepify.egrepify
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
        print('Python test file functionality removed')
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
    local HOME = os.getenv('HOME') .. '/'
    local cwd = vim.fn.getcwd()

    if vim.startswith(cwd, HOME .. 'Sync/notes') then
        require('dennich').create_weekly_note()
    else
        require('dennich').open_track_md()
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
