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

vim.cmd('colorscheme rose-pine')

vim.api.nvim_create_autocmd('ExitPre', {
    group = vim.api.nvim_create_augroup('Exit', { clear = true }),
    command = 'set guicursor=a:hor20',
    desc = 'Set cursor back to beam when leaving Neovim.',
})

vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('CustomizeWebDev', { clear = true }),
    pattern = { '*.js', '*.jsx', '*.ts', '*.tsx', '*.html', '*.css', '*.scss' },
    callback = function()
        vim.bo.shiftwidth = 2
    end,
})
