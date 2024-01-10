vim.api.nvim_win_set_option(0, 'wrap', true)

vim.keymap.set('n', '<C-N>', function()
    require('me').cycle_notes('up')
end)

vim.keymap.set('n', '<C-P>', function()
    require('me').cycle_notes('down')
end)
-- vim.api.nvim_win_set_option(0, 'conceallevel', 1)
