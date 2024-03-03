return {
    {
        'preservim/vim-pencil',
    },
    {
        'NvChad/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup({
                filetypes = {
                    'html',
                    'css',
                    'sass',
                    'scss',
                    'javascript',
                    'javascriptreact',
                    'typescript',
                    'typescriptreact',
                    'vue',
                    'svelte',
                    'lua',
                },
                user_default_options = {
                    mode = 'virtualtext',
                    names = false,
                },
            })
        end,
    },
    {
        'kndndrj/nvim-dbee',
        dependencies = {
            'MunifTanjim/nui.nvim',
        },
        build = function()
            -- Install tries to automatically detect the install method.
            -- if it fails, try calling it with one of these parameters:
            --    "curl", "wget", "bitsadmin", "go"
            require('dbee').install('go')
        end,
        config = function()
            require('dbee').setup( --[[optional config]])
        end,
    },
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        config = function()
            local harpoon = require('harpoon')
            harpoon:setup()
            -- basic telescope configuration
            local conf = require('telescope.config').values
            local function toggle_telescope(harpoon_files)
                local file_paths = {}
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(file_paths, item.value)
                end

                require('telescope.pickers')
                    .new({}, {
                        prompt_title = 'Harpoon',
                        finder = require('telescope.finders').new_table({
                            results = file_paths,
                        }),
                        previewer = conf.file_previewer({}),
                        sorter = conf.generic_sorter({}),
                    })
                    :find()
            end

            vim.keymap.set('n', '<C-e>', function()
                toggle_telescope(harpoon:list())
            end, { desc = 'Open harpoon window' })
            vim.keymap.set('n', '<C-a>', function()
                harpoon:list():append()
            end)
            -- vim.keymap.set('n', '<C-e>', function()
            --     harpoon.ui:toggle_quick_menu(harpoon:list())
            -- end)

            vim.keymap.set('n', '<leader>h', function()
                harpoon:list():select(1)
            end)
            vim.keymap.set('n', '<leader>j', function()
                harpoon:list():select(2)
            end)
            vim.keymap.set('n', '<leader>k', function()
                harpoon:list():select(3)
            end)
            -- vim.keymap.set('n', '<C-s>', function()
            --     harpoon:list():select(4)
            -- end)

            vim.keymap.set('n', '<C-P>', function()
                harpoon:list():prev()
            end)
            vim.keymap.set('n', '<C-N>', function()
                harpoon:list():next()
            end)
        end,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'telescope/telescope.nvim',
        },
    },
    {
        { 'akinsho/toggleterm.nvim', version = '*', opts = {} },
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
                query = vim.treesitter.query.parse(
                    'markdown',
                    [[
                (atx_heading [
                    (atx_h1_marker)
                    (atx_h2_marker)
                    (atx_h3_marker)
                    (atx_h4_marker)
                    (atx_h5_marker)
                    (atx_h6_marker)
                ] @headline)

                (thematic_break) @dash

                (fenced_code_block) @codeblock

                (block_quote_marker) @quote
                (block_quote (paragraph (inline (block_continuation) @quote)))
                (block_quote (paragraph (block_continuation) @quote))
                (block_quote (block_continuation) @quote)
            ]]
                ),
                headline_highlights = { 'Headline' },
                bullet_highlights = {
                    '@text.title.1.marker.markdown',
                    '@text.title.2.marker.markdown',
                    '@text.title.3.marker.markdown',
                    '@text.title.4.marker.markdown',
                    '@text.title.5.marker.markdown',
                    '@text.title.6.marker.markdown',
                },
                -- bullets = { '◉', '○', '✸', '✿' },
                bullets = {},
                codeblock_highlight = 'CodeBlock',
                dash_highlight = 'Dash',
                dash_string = '-',
                quote_highlight = 'Quote',
                quote_string = '┃',
                fat_headlines = false,
                fat_headline_upper_string = '▃',
                fat_headline_lower_string = '🬂',
            },
        },
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },

    { 'folke/which-key.nvim', opts = {} },
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
    -- {
    --     'rcarriga/nvim-notify',
    --     opts = function()
    --         vim.notify = require('notify')
    --         require('notify').setup({
    --             background_colour = '#000000',
    --         })
    --     end,
    -- },
    {
        'j-hui/fidget.nvim',
        opts = {},
        -- tag = 'legacy'
    },
    -- { 'm-demare/hlargs.nvim',    opts = {} },
    { 'lewis6991/gitsigns.nvim', opts = {} },
    { 'windwp/nvim-autopairs', opts = {} },
    {
        'ggandor/leap.nvim',
        opts = function()
            require('leap').set_default_keymaps()
        end,
    },
    -- {
    --     'utilyre/barbecue.nvim',
    --     opts = {
    --         show_modified = true,
    --         theme = {
    --             dirname = { fg = '#737aa2' },
    --         },
    --     },
    --     name = 'barbecue',
    --     version = '*',
    --     dependencies = {
    --         'SmiteshP/nvim-navic',
    --         'nvim-tree/nvim-web-devicons',
    --     },
    -- },
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
}
