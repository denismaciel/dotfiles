-- For whatever reason, I couldn't get the `nvim_set_hl` calls to execute and
-- "stay" at startup, so I needed to create an autocommand for it to be always
-- executed.
local group = vim.api.nvim_create_augroup('OverrideHighlight', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        -- vim.api.nvim_set_hl(0, 'IncSearch', { bg = '#eb9234', fg = '#000000' })
    end,
    group = group,
})

return {
    -- === Colors ===
    'folke/tokyonight.nvim',
    -- 'gbprod/nord.nvim',
    'shaunsingh/nord.nvim',
    { 'catppuccin/nvim', name = 'catppuccin' },
    'morhetz/gruvbox',
    'savq/melange',
    'rebelot/kanagawa.nvim',
    {
        'aktersnurra/no-clown-fiesta.nvim',
        opts = {
            styles = { type = { bold = true }, comments = { italic = true } },
        },
    },
    'nyoom-engineering/oxocarbon.nvim',
}
