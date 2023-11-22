local group = vim.api.nvim_create_augroup('CustomizeGo', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        vim.b.EditorConfig_disable = 1
        vim.bo.shiftwidth = 6
        vim.bo.expandtab = false
        vim.bo.tabstop = 6
        vim.opt.list = true
        vim.opt.listchars =
            'tab:▸ ,trail:·,nbsp:␣,extends:❯,precedes:❮'
    end,
    group = group,
})
