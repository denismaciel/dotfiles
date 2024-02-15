local group = vim.api.nvim_create_augroup('CustomizePython', { clear = true })
vim.api.nvim_create_autocmd('BufEnter,BufWritePre', {
    callback = function()
        -- Make sure that neovim doesn't randomly
        -- start using tabs instead of spaces.
        vim.api.nvim_buf_set_option(0, 'expandtab', true)
        vim.api.nvim_buf_set_option(0, 'shiftwidth', 4)
        vim.api.nvim_buf_set_option(0, 'tabstop', 4)
    end,
    group = group,
})
