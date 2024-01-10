-- -- Bootstrap lazy.nvim
-- local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
-- if not vim.loop.fs_stat(lazypath) then
--     vim.fn.system({
--         'git',
--         'clone',
--         '--filter=blob:none',
--         '--single-branch',
--         'https://github.com/folke/lazy.nvim.git',
--         lazypath,
--     })
-- end
-- vim.opt.runtimepath:prepend(lazypath)
-- require('lazy').setup({
--     {
--         'neovim/nvim-lspconfig',
--         config = function()
--             -- LSP server setup
--             local lspconfig = require('lspconfig')
--
--             -- Example: Set up 'pyright' for Python
--             lspconfig.pyright.setup({
--                 settings = {
--                     python = {
--                         exclude = {
--                             'venv',
--                             'venv-*',
--                         },
--                         analysis = {
--                             autoSearchPaths = false,
--                             useLibraryCodeForTypes = true,
--                             typeCheckingMode = 'off',
--                         },
--                     },
--                 },
--             })
--         end,
--     }, -- LSP Configurations
-- })
--
--
vim.lsp.start({
    name = 'pyright',
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_dir = vim.fs.dirname(
        vim.fs.find({ 'setup.py', 'pyproject.toml' }, { upward = true })[1]
    ),
})

vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.implementation)
vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
