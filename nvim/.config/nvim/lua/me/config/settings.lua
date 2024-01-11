vim.g.python3_host_prog = os.getenv('HOME') .. '/venvs/neovim/bin/python'
vim.g.mapleader = ' '

local o = vim.opt

vim.cmd('set shortmess+=I')

o.signcolumn = 'yes'
o.clipboard = o.clipboard + 'unnamedplus'
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

o.cursorline = true

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
-- o.winbar = '%=%m %f'
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

-- Remove cursorline and cursorcolumn when when window is unfocused
local function autocmd(events, ...)
    vim.api.nvim_create_autocmd(events, { callback = ... })
end

local old_guicursor, old_cursorline, old_cursorcolumn
autocmd('VimEnter', function()
    old_guicursor = o.guicursor
    old_cursorline = o.cursorline
    old_cursorcolumn = o.cursorcolumn
end)

autocmd({ 'WinLeave', 'FocusLost' }, function()
    vim.opt.guicursor = 'a:noCursor'
    vim.opt.cursorline = false
    vim.opt.cursorcolumn = false
end)

autocmd({ 'WinEnter', 'FocusGained' }, function()
    vim.opt.guicursor = old_guicursor
    vim.opt.cursorline = old_cursorline
    vim.opt.cursorcolumn = old_cursorcolumn
end)
