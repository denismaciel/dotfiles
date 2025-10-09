return {
    { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
    { 'projekt0n/github-nvim-theme', name = 'github-theme' },
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000,
        config = true,
    },
    {
        'sainnhe/gruvbox-material',
        priority = 1000,
        config = function()
            vim.g.gruvbox_material_background = 'hard'
            vim.g.gruvbox_material_foreground = 'material'
            vim.g.gruvbox_material_enable_italic = 1
            vim.g.gruvbox_material_disable_italic_comment = 0
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_transparent_background = 0
        end,
    },
    {
        'aktersnurra/no-clown-fiesta.nvim',
        opts = {
            transparent = false,
            styles = { type = { bold = true }, comments = { italic = true } },
        },
    },
}
