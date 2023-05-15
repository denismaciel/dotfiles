local group = vim.api.nvim_create_augroup('CustomizeMakefile', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        vim.bo.expandtab = false
        vim.api.nvim_buf_set_option(0, 'expandtab', false)
    end,
    group = group,
})
