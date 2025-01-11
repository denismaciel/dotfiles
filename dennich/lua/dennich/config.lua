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

o.laststatus = 0
o.cmdheight = 0
o.showmode = false
o.ruler = false
o.showcmd = false

if os.getenv('MODE') == 'notebook' then
    vim.keymap.set('n', '<c-j>', ':tabnext<cr>')
    vim.keymap.set('n', '<c-k>', ':tabprev<cr>')
end

vim.cmd([[ colorscheme no-clown-fiesta ]])
-- vim.cmd([[ colorscheme kanagawa ]])

vim.cmd('cabbrev W w')
vim.cmd('cabbrev Wq wq')
vim.cmd('cabbrev WQ wq')

vim.cmd('command! Bd bp | sp | bn | bd')
vim.cmd('command! Bdd bp! | sp! | bn! | bd!')
vim.cmd('cabbrev bd Bd')
vim.cmd('cabbrev bd! Bdd')
vim.cmd('cabbrev Bd! Bdd')

vim.cmd([[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=200}
augroup END
]])

vim.diagnostic.config({
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

vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('CustomizeWebDev', { clear = true }),
    pattern = { '*.js', '*.jsx', '*.ts', '*.tsx', '*.html', '*.css', '*.scss' },
    callback = function()
        vim.api.nvim_buf_set_option(0, 'shiftwidth', 2)
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

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        local file_path = vim.fn.expand('%:p')
        if file_path == '/tmp/tmux_pane_content' then
            vim.cmd('colorscheme tokyonight')
        end
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

local sql = require('dennich.sql')
local dennich = require('dennich')

-- Stolen from https://github.com/tjdevries/config_manager/blob/ee11710c4ad09e0b303e5030b37c86ad8674f8b2/xdg_config/nvim/lua/tj/lsp/handlers.lua#L30
local implementation = function()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(
        0,
        'textDocument/implementation',
        params,
        function(err, result, ctx, config)
            local bufnr = ctx.bufnr
            local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

            -- In go code, I do not like to see any mocks for impls
            if ft == 'go' then
                local new_result = vim.tbl_filter(function(v)
                    return not string.find(v.uri, '_mock')
                end, result)

                if #new_result > 0 then
                    result = new_result
                end
            end

            vim.lsp.handlers['textDocument/implementation'](
                err,
                result,
                ctx,
                config
            )
            vim.cmd([[normal! zz]])
        end
    )
end

vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', implementation)
vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
vim.keymap.set('n', 'grn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>;', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
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

vim.keymap.set(
    'n',
    '<leader>fc',
    require('dennich').copy_file_path_to_clipboard,
    { desc = 'Copy file path to clipboard' }
)
vim.keymap.set('n', '<leader>ff', function()
    vim.lsp.buf.format()
    require('conform').format()
end, { desc = 'Format current buffer' })
vim.keymap.set(
    'n',
    '<leader>xx',
    '<cmd>Trouble diagnostics toggle<cr>',
    { desc = 'Diagnostics (Trouble)' }
)
vim.keymap.set(
    'n',
    '<leader>xd',
    '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    { desc = 'Document Diagnostics' }
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
    '<leader>ss',
    ':!sqly snapshot --file % --cte-name <cword> <CR>',
    { desc = 'Snapshot CTE' }
)
vim.keymap.set(
    'n',
    '<leader>sx',
    sql.dbt_open_compiled,
    { desc = 'Open compiled query' }
)
vim.keymap.set('n', '<leader>sr', sql.dbt_open_run, { desc = 'Open run query' })
vim.keymap.set(
    'n',
    '<leader>sv',
    sql.dbt_open_snaps,
    { desc = 'Open snapshots' }
)
vim.keymap.set(
    'n',
    '<leader>sn',
    ':!echo -n %:t:r | xclip -selection clipboard<CR>',
    { desc = 'Copy model name to clipboard' }
)
vim.keymap.set('n', '<leader>st', function()
    require('telescope.builtin').find_files({
        find_command = {
            'rg',
            '--files',
            '--hidden',
            '-g',
            '!.git',
            '-g',
            '!.snapshots/',
        },
        cwd = '/home/denis/.cache/recap/bigquery-schema/',
    })
end, { desc = 'Find table schema' })

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
    require('telescope.builtin').find_files({
        find_command = {
            'rg',
            '--files',
            '--hidden',
            '-g',
            '!.git',
            '-g',
            '!.snapshots/',
        },
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
        require('dennich').python_test_file()
    else
        print('No implementation for filetype: ' .. ft)
    end
end

vim.keymap.set('n', '<leader>ro', open_test_file)

local function open_parrot_code()
    vim.cmd('PrtWriteCode')
    vim.cmd('only')
end
vim.api.nvim_create_user_command('OpenParrot', open_parrot_code, {})

vim.keymap.set('n', '<leader>gn', '<cmd>PrtChatNew<cr>')
vim.keymap.set(
    'n',
    '<leader>gc',
    open_parrot_code,
    { noremap = true, silent = true, desc = 'PrtWriteCode' }
)
vim.keymap.set('n', '<leader>gf', '<cmd>PrtChatFile<cr>', {})
vim.keymap.set('n', '<leader>go', '<cmd>PrtCompleteFullContext<cr>', {})

vim.keymap.set('n', '<leader>rr', function()
    package.loaded['dennich'] = nil
    require('dennich').run()
end)
