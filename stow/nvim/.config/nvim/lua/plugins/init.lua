return {
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
    'nvimtools/none-ls.nvim',
    {
        'j-hui/fidget.nvim',
        opts = {},
    },
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end
                    -- Navigation
                    map('n', ']c', function()
                        if vim.wo.diff then
                            return ']c'
                        end
                        vim.schedule(function()
                            gs.next_hunk()
                        end)
                        return '<Ignore>'
                    end, { expr = true })

                    map('n', '[c', function()
                        if vim.wo.diff then
                            return '[c'
                        end
                        vim.schedule(function()
                            gs.prev_hunk()
                        end)
                        return '<Ignore>'
                    end, { expr = true })

                    -- Actions
                    map('n', '<leader>hs', gs.stage_hunk)
                    map('n', '<leader>hr', gs.reset_hunk)
                    map('v', '<leader>hs', function()
                        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                    end)
                    map('v', '<leader>hr', function()
                        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                    end)
                    map('n', '<leader>hS', gs.stage_buffer)
                    map('n', '<leader>hu', gs.undo_stage_hunk)
                    map('n', '<leader>hR', gs.reset_buffer)
                    map('n', '<leader>hp', gs.preview_hunk)
                    map('n', '<leader>hb', function()
                        gs.blame_line({ full = true })
                    end)
                    map('n', '<leader>tb', gs.toggle_current_line_blame)
                    map('n', '<leader>hd', gs.diffthis)
                    map('n', '<leader>hD', function()
                        gs.diffthis('~')
                    end)
                    map('n', '<leader>td', gs.toggle_deleted)

                    -- Text object
                    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end,
            })
        end,
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
            opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = true,
            },
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
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
    },
    {
        'folke/trouble.nvim',
        opts = {},
    },

    -- Colors
    {
        'aktersnurra/no-clown-fiesta.nvim',
        opts = {
            transparent = false,
            styles = { type = { bold = true }, comments = { italic = true } },
        },
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
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'ruff_fix', 'ruff_format' },
                typescript = { 'biome' },
                typescriptreact = { 'biome' },
                javascript = { 'biome' },
                javascriptreact = { 'biome' },
            },
            formatters = {
                biome = {
                    cwd = function()
                        return '/home/denis'
                    end,
                },
            },
        },
    },
    -- https://www.reddit.com/r/vim/comments/d77t6j/guide_how_to_setup_ctags_with_gutentags_properly/
    {
        'ludovicchabant/vim-gutentags',
        config = function()
            vim.g.gutentags_ctags_exclude = {
                '.direnv',
                '*.git',
                '*.svg',
                '*.hg',
                '*/tests/*',
                'build',
                'dist',
                '*sites/*/files/*',
                'bin',
                'node_modules',
                'bower_components',
                'cache',
                'compiled',
                'docs',
                'example',
                'bundle',
                'vendor',
                '*.md',
                '*-lock.json',
                '*.lock',
                '*bundle*.js',
                '*build*.js',
                '.*rc*',
                '*.json',
                '*.min.*',
                '*.map',
                '*.bak',
                '*.zip',
                '*.pyc',
                '*.class',
                '*.sln',
                '*.Master',
                '*.csproj',
                '*.tmp',
                '*.csproj.user',
                '*.cache',
                '*.pdb',
                'tags*',
                'cscope.*',
                -- '*.css',
                -- '*.less',
                -- '*.scss',
                '*.exe',
                '*.dll',
                '*.mp3',
                '*.ogg',
                '*.flac',
                '*.swp',
                '*.swo',
                '*.bmp',
                '*.gif',
                '*.ico',
                '*.jpg',
                '*.png',
                '*.rar',
                '*.zip',
                '*.tar',
                '*.tar.gz',
                '*.tar.xz',
                '*.tar.bz2',
                '*.pdf',
                '*.doc',
                '*.docx',
                '*.ppt',
                '*.pptx',
            }
            vim.g.gutentags_add_default_project_roots = false
            vim.g.gutentags_project_root = {
                'package.json',
                'go.mod',
                'requirements.txt',
                '.git',
                'pyproject.toml',
            }
            -- vim.g.gutentags_cache_dir = vim.fn.expand '~/.cache/nvim/ctags/'
            vim.g.gutentags_generate_on_new = true
            vim.g.gutentags_generate_on_missing = true
            vim.g.gutentags_generate_on_write = true
            vim.g.gutentags_generate_on_empty_buffer = true
            vim.cmd(
                [[command! -nargs=0 GutentagsClearCache call system('rm ' . g:gutentags_cache_dir . '/*')]]
            )
            vim.g.gutentags_ctags_extra_args =
                { '--tag-relative=yes', '--fields=+ailmnS' }
        end,
    },
}
