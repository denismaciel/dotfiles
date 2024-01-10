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
require('me.config.cmp')
require('me.config.dap')
require('me.config.mappings')
require('me.config.telescope')

vim.cmd('colorscheme tokyonight-moon')

local me = require('me')
me.maybe_toggle_shorts_mode()
