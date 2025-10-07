return {
    { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
    { 'projekt0n/github-nvim-theme', name = 'github-theme' },
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000,
        config = true,
    },
    {
        'aktersnurra/no-clown-fiesta.nvim',
        opts = {
            transparent = false,
            styles = { type = { bold = true }, comments = { italic = true } },
        },
    },
}
