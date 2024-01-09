return {
    -- {
    --     'folke/noice.nvim',
    --     event = 'VeryLazy',
    --     opts = {
    --         messages = {
    --             enable = false,
    --         },
    --         lsp = {
    --             -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    --             override = {
    --                 ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
    --                 ['vim.lsp.util.stylize_markdown'] = true,
    --                 ['cmp.entry.get_documentation'] = true,
    --             },
    --         },
    --         -- you can enable a preset for easier configuration
    --         presets = {
    --             bottom_search = true, -- use a classic bottom cmdline for search
    --             command_palette = true, -- position the cmdline and popupmenu together
    --             long_message_to_split = true, -- long messages will be sent to a split
    --             inc_rename = false, -- enables an input dialog for inc-rename.nvim
    --             lsp_doc_border = false, -- add a border to hover docs and signature help
    --         },
    --     },
    --     dependencies = {
    --         'MunifTanjim/nui.nvim',
    --         'rcarriga/nvim-notify',
    --     },
    -- },
    'dkarter/bullets.vim',
    {
        'mickael-menu/zk-nvim',
        config = function()
            require('zk').setup {
                picker = 'telescope',
            }
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
                    welcome_message = 'Hello',
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
        dependencies = { { 'nvim-lua/plenary.nvim' } },
    },
    -- {
    --     'nvim-telescope/telescope-frecency.nvim',
    --     config = function()
    --         require('telescope').load_extension 'frecency'
    --     end,
    -- },
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
            require('zen-mode').setup {
                window = {
                    width = 120,
                },
            }
        end,
    },

    { 'kylechui/nvim-surround', opts = {} },
    'jose-elias-alvarez/null-ls.nvim',
    {
        'rcarriga/nvim-notify',
        opts = function()
            vim.notify = require 'notify'
            require('notify').setup {
                background_colour = '#000000',
            }
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

    -- == LSP ===
    'neovim/nvim-lspconfig',
    {
        'folke/trouble.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        opts = {
            colors = {
                fg = '#ffffff',
            },
        },
    },
    -- 'simrat39/inlay-hints.nvim',
    { 'williamboman/mason.nvim', opts = {} },
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
        opts = function()
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
