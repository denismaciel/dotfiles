require('me.config.settings')

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
