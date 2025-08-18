local group = vim.api.nvim_create_augroup('MakefileSettings', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
    pattern = { '**/[Mm]akefile', '*.mk' },
    callback = function()
        vim.api.nvim_set_option_value('expandtab', false, { buf = 0 })
    end,
    group = group,
})
