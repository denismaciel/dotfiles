return {
    'pmizio/typescript-tools.nvim',
    event = 'BufReadPre',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
    config = function()
        require('typescript-tools').setup({})
    end,
}
