return {
    { 'sindrets/diffview.nvim' },
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        opts = {
            bigfile = { enabled = true },
        },
    },
    {
        'ibhagwan/fzf-lua',
        -- optional for icon support
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        -- or if using mini.icons/mini.nvim
        -- dependencies = { "echasnovski/mini.icons" },
        opts = {},
    },
    {
        'Pocco81/auto-save.nvim',
        config = function()
            require('auto-save').setup({
                enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
                execution_message = {
                    message = function() -- message to print on save
                        -- return 'AutoSave: saved at ' .. vim.fn.strftime('%H:%M:%S')
                        return ''
                    end,
                    dim = 0.02, -- dim the color of `message`
                    cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
                },
                trigger_events = { 'InsertLeave' }, -- vim events that trigger auto-save. See :h events
                -- function that determines whether to save the current buffer or not
                -- return true: if buffer is ok to be saved
                -- return false: if it's not ok to be saved
                condition = function(buf)
                    if
                        vim.fn.getbufvar(buf, '&modifiable') == 1
                        and vim.fn.getbufvar(buf, '&filetype') == 'markdown'
                    then
                        return true -- met condition(s), can save
                    end
                    return false -- can't save
                end,
                write_all_buffers = false, -- write all buffers when the current one meets `condition`
                debounce_delay = 135, -- saves the file at most every `debounce_delay` milliseconds
                callbacks = { -- functions to be executed at different intervals
                    enabling = nil, -- ran when enabling auto-save
                    disabling = nil, -- ran when disabling auto-save
                    before_asserting_save = nil, -- ran before checking `condition`
                    before_saving = nil, -- ran before doing the actual save
                    after_saving = nil, -- ran after doing the actual save
                },
            })
        end,
    },
    {
        'catgoose/nvim-colorizer.lua',
        event = 'BufReadPre',
        opts = { user_default_options = { names = false } },
    },
    {
        'folke/which-key.nvim',
        opts = { icons = { mappings = false } },
    },
    { 'folke/neodev.nvim', opts = {} },
    {
        'j-hui/fidget.nvim',
        opts = {},
    },
    { 'windwp/nvim-autopairs', opts = {} },
    {
        'ggandor/leap.nvim',
        opts = function()
            require('leap').create_default_mappings()
        end,
    },
    'christoomey/vim-tmux-navigator',
    {
        'numToStr/Comment.nvim',
        opts = {},
        config = function()
            require('ts_context_commentstring').setup({
                enable_autocmd = false,
            })
            require('Comment').setup({
                pre_hook = require(
                    'ts_context_commentstring.integrations.comment_nvim'
                ).create_pre_hook(),
            })
        end,
        lazy = false,
        dependencies = {
            'JoosepAlviste/nvim-ts-context-commentstring',
        },
    },
    {
        'windwp/nvim-ts-autotag',
        opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = true,
        },
    },
    {
        'nvim-tree/nvim-tree.lua',
        opts = {
            view = {
                adaptive_size = true,
                float = {
                    enable = true,
                },
            },
            filters = {
                dotfiles = false,
                git_ignored = false,
                custom = {
                    '^\\.git',
                    '__pycache__',
                    '\\.egg-info$',
                },
            },
        },
    },
    {
        'folke/trouble.nvim',
        opts = {},
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'fdschmidt93/telescope-egrepify.nvim',
            'nvim-telescope/telescope-ui-select.nvim',
        },
        config = function()
            local actions = require('telescope.actions')
            local actions_layout = require('telescope.actions.layout')
            local action_state = require('telescope.actions.state')

            require('telescope').setup({
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
                defaults = {
                    mappings = {
                        n = {
                            ['h'] = actions_layout.toggle_preview,
                        },
                        i = {
                            ['<C-h>'] = actions_layout.toggle_preview,
                        },
                    },
                    path_display = { 'truncate' },
                    vimgrep_arguments = {
                        'rg',
                        '--hidden',
                        '--color=never',
                        '--no-heading',
                        '--with-filename',
                        '--line-number',
                        '--column',
                        '--smart-case',
                    },
                    file_ignore_patterns = {
                        '%.eot',
                        '%.ttf',
                        '%.woff',
                        '%.woff2',
                        '%.parquet',
                        '%.csv',
                    },
                    layout_config = {
                        width = function(_, max_columns)
                            local percentage = 0.95
                            return math.floor(percentage * max_columns)
                        end,
                        height = function(_, _, max_lines)
                            local percentage = 0.9
                            local min = 70
                            return math.max(
                                math.floor(percentage * max_lines),
                                min
                            )
                        end,
                    },
                },
                pickers = {
                    buffers = {
                        mappings = {
                            n = {
                                ['dd'] = actions.delete_buffer,
                                ['h'] = actions_layout.toggle_preview,
                            },
                        },
                    },
                    tags = {
                        mappings = {
                            n = {
                                ['df'] = actions.send_selected_to_qflist
                                    + actions.open_qflist,
                            },
                        },
                    },
                },
            })
            require('telescope').load_extension('ui-select')
            require('telescope').load_extension('egrepify')
        end,
    },
    {
        'saghen/blink.cmp',
        version = '1.*',
        opts = {
            keymap = { preset = 'default' },
            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = 'mono',
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            signature = { enabled = true },
        },
        opts_extend = { 'sources.default' },
    },
}
