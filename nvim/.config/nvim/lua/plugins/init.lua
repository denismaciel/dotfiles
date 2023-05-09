return {
    {
        'utilyre/sentiment.nvim',
        version = '*',
        opts = {},
    },
    {
        'img-paste-devs/img-paste.vim',
    },
    {
        'jackMort/ChatGPT.nvim',
        event = 'VeryLazy',
        config = function()
            local config = {
                keymaps = {
                    submit = '<C-s>',
                },
            }

            if not vim.env.OPENAI_API_KEY then
                return
            end

            require('chatgpt').setup(config)
        end,
        dependencies = {
            'MunifTanjim/nui.nvim',
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
        },
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { { 'nvim-lua/plenary.nvim' } },
    },
    'nvim-telescope/telescope-ui-select.nvim',
    -- ======================
    'folke/which-key.nvim',
    { 'folke/neodev.nvim', config = {} },
    {
        'folke/zen-mode.nvim',
        config = function()
            require('zen-mode').setup {
                window = {
                    width = 120,
                },
            }
        end,
    },

    { 'kylechui/nvim-surround', config = {} },
    'jose-elias-alvarez/null-ls.nvim',
    {
        'rcarriga/nvim-notify',
        config = function()
            vim.notify = require 'notify'
        end,
    },
    { 'j-hui/fidget.nvim', config = {} },
    { 'm-demare/hlargs.nvim', config = {} },
    { 'lewis6991/gitsigns.nvim', config = {} },
    { 'windwp/nvim-autopairs', config = {} },

    -- === DAP ===
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
    'nvim-telescope/telescope-dap.nvim',

    { 'NvChad/nvim-colorizer.lua', config = {} },
    { 'klen/nvim-test', config = {} },
    {
        'ggandor/leap.nvim',
        config = function()
            require('leap').set_default_keymaps()
        end,
    },
    {
        'utilyre/barbecue.nvim',
        config = {
            theme = {

                dirname = { fg = '#737aa2' },
            },
        },
        name = 'barbecue',
        version = '*',
        dependencies = {
            'SmiteshP/nvim-navic',
            'nvim-tree/nvim-web-devicons',
        },
    },

    'christoomey/vim-tmux-navigator',
    'nvim-lua/plenary.nvim',
    'tpope/vim-commentary',
    'editorconfig/editorconfig-vim',
    'mbbill/undotree',
    'windwp/nvim-autopairs',
    'windwp/nvim-ts-autotag',
    'APZelos/blamer.nvim',
    {
        'nvim-tree/nvim-tree.lua',
        config = {},
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        version = 'nightly',
    },
    'mhartington/formatter.nvim',

    -- == LSP ===
    'neovim/nvim-lspconfig',
    {
        'folke/trouble.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = {
            colors = {
                fg = '#ffffff',
            },
        },
    },
    'simrat39/inlay-hints.nvim',
    { 'williamboman/mason.nvim', config = {} },
    'jayp0521/mason-nvim-dap.nvim',
    'williamboman/mason-lspconfig.nvim',
    'jose-elias-alvarez/typescript.nvim',
    -- === Completion ===
    'hrsh7th/vim-vsnip',
    'hrsh7th/vim-vsnip-integ',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    {
        'L3MON4D3/LuaSnip',
        config = function()
            local luasnip = require 'luasnip'
            vim.keymap.set({ 'i', 's' }, '<C-S>', function()
                if luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                end
            end, { silent = true })
        end,
    },

    {
        'benfowler/telescope-luasnip.nvim',
        module = 'telescope._extension.luasnip', -- for lazy loading
    },
    'saadparwaiz1/cmp_luasnip',
    'rafamadriz/friendly-snippets',
    'onsails/lspkind.nvim',
}
