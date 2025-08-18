local group = vim.api.nvim_create_augroup('CustomizeNix', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        vim.bo.shiftwidth = 2
    end,
    group = group,
})
