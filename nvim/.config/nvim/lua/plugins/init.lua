return {
    'dkarter/bullets.vim',
    {
        'mickael-menu/zk-nvim',
        config = function()
            require('zk').setup({
                picker = 'telescope',
            })
        end,
    },
    {
        'jackMort/ChatGPT.nvim',
        event = 'VeryLazy',
        config = function()
            local config = {
                keymaps = {
                    submit = '<C-s>',
                    toggle_sessions = '<C-t>',
                },
                openai_params = {
                    model = 'gpt-4',
                },
                openai_edit_params = {
                    model = 'gpt-4',
                },
                chat = {
                    welcome_message = '🥶',
                },
            }
            --
            -- if not vim.env.OPENAI_API_KEY then
            --     return
            -- end

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
        dependencies = { 'nvim-lua/plenary.nvim' },
    },
    'nvim-telescope/telescope-ui-select.nvim',
    {
        'lukas-reineke/headlines.nvim',
        opts = {
            markdown = {
                headline_highlights = {
                    'Headline1',
                    'Headline2',
                    'Headline3',
                    'Headline4',
                    'Headline5',
                    'Headline6',
                },
                codeblock_highlight = 'CodeBlock',
                dash_highlight = 'Dash',
                quote_highlight = 'Quote',
                fat_headlines = false,
            },
        },
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },

    -- ======================
    'folke/which-key.nvim',
    { 'folke/neodev.nvim', opts = {} },
    {
        'folke/zen-mode.nvim',
        opts = function()
            require('zen-mode').setup({
                window = {
                    width = 120,
                },
            })
        end,
    },

    { 'kylechui/nvim-surround', opts = {} },
    'nvimtools/none-ls.nvim',
    {
        'rcarriga/nvim-notify',
        opts = function()
            vim.notify = require('notify')
            require('notify').setup({
                background_colour = '#000000',
            })
        end,
    },
    {
        'j-hui/fidget.nvim',
        opts = {},
        -- tag = 'legacy'
    },
    -- { 'm-demare/hlargs.nvim',    opts = {} },
    { 'lewis6991/gitsigns.nvim', opts = {} },
    { 'windwp/nvim-autopairs', opts = {} },

    -- === DAP ===
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
    'nvim-telescope/telescope-dap.nvim',

    -- { 'NvChad/nvim-colorizer.lua', opts = {} },
    { 'klen/nvim-test', opts = {} },
    {
        'ggandor/leap.nvim',
        opts = function()
            require('leap').set_default_keymaps()
        end,
    },
    {
        'utilyre/barbecue.nvim',
        opts = {
            show_modified = true,
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
    {
        'numToStr/Comment.nvim',
        opts = {},
    },
    'mbbill/undotree',
    'windwp/nvim-autopairs',
    'windwp/nvim-ts-autotag',
    'APZelos/blamer.nvim',
    {
        'nvim-tree/nvim-tree.lua',
        opts = {
            view = {
                width = 70,
            },
            filters = {
                dotfiles = false,
            },
        },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        version = 'nightly',
    },
    {
        'folke/trouble.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        opts = {
            colors = {
                fg = '#ffffff',
            },
        },
    },
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
        opts = function()
            local luasnip = require('luasnip')
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
