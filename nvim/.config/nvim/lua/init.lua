vim.g.python3_host_prog = os.getenv('HOME') .. '/venvs/neovim/bin/python'
vim.g.mapleader = ' '

local o = vim.opt

vim.cmd('set shortmess+=I')

o.signcolumn = 'yes'
o.clipboard = 'unnamedplus'
o.formatoptions = o.formatoptions + 'cro'
o.mouse = 'a'
o.tabstop = 4     -- how many spaces a tab is when vim reads a file
o.softtabstop = 4 --how many spaces are inserted when you hit tab
o.shiftwidth = 4
o.autoindent = true
o.expandtab = true
o.hidden = true -- switch buffers without saving
o.wrap = false
o.number = false
o.termguicolors = true
o.backspace = { 'indent', 'eol', 'start' }
o.showcmd = false  -- show command in bottom bar
o.showmatch = true -- highlight matching parenthesis

o.backup = false
o.swapfile = false
o.wrap = false

-- Search
o.incsearch = true -- search as characters are entered
o.hlsearch = true  -- highlight matches
o.ignorecase = true
o.smartcase = true
o.scrolloff = 10 -- keep X lines above and below the cusrsor when scrolling

-- o.cursorline = true
-- o.cursorlineopt = 'number'

o.undodir = os.getenv('HOME') .. '/.config/nvim/undodir'

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

o.laststatus = 3
o.winbar = '%=%m %f'
o.showmode = false
o.ruler = false
o.showcmd = false

vim.cmd('cabbrev W w')
vim.cmd('cabbrev Wq wq')
vim.cmd('cabbrev WQ wq')
vim.cmd('cabbrev bd Bd')
vim.cmd('cabbrev bd! Bdd')
vim.cmd('cabbrev Bd! Bdd')

vim.cmd([[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=200}
augroup END
]])

vim.cmd([[
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
]])

local signs = { Error = '•', Warn = '•', Hint = '•', Info = '•' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

vim.api.nvim_create_autocmd('ExitPre', {
    group = vim.api.nvim_create_augroup('Exit', { clear = true }),
    command = 'set guicursor=a:hor20',
    desc = 'Set cursor back to beam when leaving Neovim.',
})

-- -- Remove cursorline and cursorcolumn when when window is unfocused
-- local function autocmd(events, ...)
--     vim.api.nvim_create_autocmd(events, { callback = ... })
-- end
--
-- local old_guicursor, old_cursorline, old_cursorcolumn
-- autocmd('VimEnter', function()
--     old_guicursor = o.guicursor
--     old_cursorline = o.cursorline
--     old_cursorcolumn = o.cursorcolumn
-- end)
--
-- autocmd({ 'WinLeave', 'FocusLost' }, function()
--     vim.opt.guicursor = 'a:noCursor'
--     vim.opt.cursorline = false
--     vim.opt.cursorcolumn = false
-- end)
--
-- autocmd({ 'WinEnter', 'FocusGained' }, function()
--     vim.opt.guicursor = old_guicursor
--     vim.opt.cursorline = old_cursorline
--     vim.opt.cursorcolumn = old_cursorcolumn
-- end)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--single-branch',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)
require('lazy').setup('plugins')
require('me.config.mappings')
local palette = require('no-clown-fiesta.palette')

local augroup_highlight_todo = 'DennichHighlightTODO'
local highlight_group_done = 'DennichDONE'
vim.api.nvim_create_augroup(augroup_highlight_todo, { clear = true })
-- Autocommand to extend Neovim's syntax to match `TODO` and `DONE`
vim.api.nvim_create_autocmd({ 'WinEnter', 'VimEnter' }, {
    group = augroup_highlight_todo,
    pattern = '*',
    callback = function()
        vim.fn.matchadd(highlight_group_done, 'DONE', -1)
        -- `Todo` is a prexisting highlight group that we leverage to highlight
        -- `TODO`.
        -- For `DONE`, we create need a new highlight group and set the `strikethrough`
        vim.fn.matchadd('Todo', 'TODO', -1)
    end,
})
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    group = augroup_highlight_todo,
    callback = function()
        vim.api.nvim_set_hl(
            0,
            highlight_group_done,
            { strikethrough = true, fg = 'gray' }
        )
        vim.api.nvim_set_hl(0, 'Todo', { bold = true, fg = palette.roxo })
        vim.api.nvim_set_hl(0, 'CodeBlock', { bg = palette.accent })
    end,
})

vim.cmd('colorscheme no-clown-fiesta')

-- vim.api.nvim_create_autocmd('ExitPre', {
--     group = vim.api.nvim_create_augroup('Exit', { clear = true }),
--     command = 'set guicursor=a:hor20',
--     desc = 'Set cursor back to beam when leaving Neovim.',
-- })
--
-- vim.opt.guicursor = "n-v-i-c:block-Cursor"
vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'

vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('CustomizeWebDev', { clear = true }),
    pattern = { '*.js', '*.jsx', '*.ts', '*.tsx', '*.html', '*.css', '*.scss' },
    callback = function()
        vim.bo.shiftwidth = 2
    end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup('CustomizeEnv', { clear = true }),
    pattern = { '.env.*' },
    callback = function()
        vim.bo.filetype = 'sh'
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
