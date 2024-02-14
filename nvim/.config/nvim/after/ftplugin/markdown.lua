local me = require('me')

vim.cmd('SoftPencil')

me.highlight_markdown_titles()

local group = vim.api.nvim_create_augroup('CustomizeNix', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        vim.api.nvim_win_set_option(0, 'wrap', true)
        vim.api.nvim_buf_set_option(0, 'shiftwidth', 2)
        vim.api.nvim_buf_set_option(0, 'conceallevel', 0)
    end,
    group = group,
})

vim.keymap.set('n', '<C-N>', function()
    require('me').cycle_notes('down')
end)

vim.keymap.set('n', '<C-P>', function()
    require('me').cycle_notes('up')
end)
