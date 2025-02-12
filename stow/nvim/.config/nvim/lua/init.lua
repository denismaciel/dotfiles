-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--single-branch',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

local function read_file(file_path)
    local file, error_message = io.open(file_path, 'r')
    if file then
        local content = file:read('*all')
        -- trim trailing and
        content = content:gsub('^%s+', ''):gsub('%s+$', '')
        file:close()
        return content
    else
        error(
            'Unable to open the file: '
                .. file_path
                .. '\nError: '
                .. error_message
        )
    end
end

-- ============================
-- Plugins
-- ============================
require('lazy').setup({
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            -- dashboard = { enabled = true },
            -- indent = { enabled = true },
            input = { enabled = true },
            -- notifier = { enabled = true },
            quickfile = { enabled = true },
            -- scroll = { enabled = true },
            -- statuscolumn = { enabled = true },
            words = { enabled = true },
            terminal = { enabled = true },
        },
        keys = {
            -- {
            --     '<c-a>',
            --     function()
            --         Snacks.terminal.toggle()
            --         vim.keymap.set({ 't' }, '<c-a>', Snacks.terminal.toggle)
            --     end,
            --     desc = 'Toggle Terminal',
            -- },
            -- {
            --     '<leader>xt',
            --     function()
            --         Snacks.terminal.toggle()
            --     end,
            --     desc = 'Toggle Terminal',
            -- },
        },
    },
    -- {
    --     'milanglacier/minuet-ai.nvim',
    --     event = { 'InsertEnter' },
    --     config = function()
    --         require('minuet').setup({
    --             provider = 'gemini',
    --             request_timeout = 4,
    --             throttle = 2000,
    --             virtualtext = {
    --                 auto_trigger_ft = { 'python', 'lua' },
    --                 keymap = {
    --                     accept = '<A-A>',
    --                     accept_line = '<A-a>',
    --                     prev = '<A-[>',
    --                     next = '<A-]>',
    --                     dismiss = '<A-e>',
    --                 },
    --             },
    --             notify = 'error',
    --             provider_options = {
    --                 gemini = {
    --                     optional = {
    --                         generationConfig = {
    --                             maxOutputTokens = 256,
    --                             topP = 0.9,
    --                         },
    --                         safetySettings = {
    --                             {
    --                                 category = 'HARM_CATEGORY_DANGEROUS_CONTENT',
    --                                 threshold = 'BLOCK_NONE',
    --                             },
    --                             {
    --                                 category = 'HARM_CATEGORY_HATE_SPEECH',
    --                                 threshold = 'BLOCK_NONE',
    --                             },
    --                             {
    --                                 category = 'HARM_CATEGORY_HARASSMENT',
    --                                 threshold = 'BLOCK_NONE',
    --                             },
    --                             {
    --                                 category = 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
    --                                 threshold = 'BLOCK_NONE',
    --                             },
    --                         },
    --                     },
    --                 },
    --             },
    --         })
    --     end,
    -- },
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'leoluz/nvim-dap-go',
            'mfussenegger/nvim-dap-python',
            'nvim-neotest/nvim-nio',
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
        },
        config = function()
            require('dap-python').setup('uv')
            require('dapui').setup()
            require('dap-go').setup()

            require('nvim-dap-virtual-text').setup({})

            -- Handled by nvim-dap-go
            -- dap.adapters.go = {
            --   type = "server",
            --   port = "${port}",
            --   executable = {
            --     command = "dlv",
            --     args = { "dap", "-l", "127.0.0.1:${port}" },
            --   },
            -- }

            vim.keymap.set(
                'n',
                '<space>db',
                require('dap').toggle_breakpoint,
                { desc = '[dap] toogle breakpoint' }
            )
            vim.keymap.set(
                'n',
                '<space>dgb',
                require('dap').run_to_cursor,
                { desc = '[dap] run to cursor' }
            )

            -- Eval var under cursor
            vim.keymap.set('n', '<space>?', function()
                require('dapui').eval(nil, { enter = true })
            end)
            table.insert(require('dap').configurations.python, {
                type = 'python',
                request = 'launch',
                name = 'pycap 🐝',
                program = '${workspaceFolder}/src/pycap/risk_model/scripts/debug.py',
                args = { 'run-risk-model' },
                console = 'integratedTerminal',
                cwd = '${workspaceFolder}',
            })
            table.insert(require('dap').configurations.python, {
                type = 'python',
                request = 'launch',
                name = 'samwise',
                program = '${workspaceFolder}/src/samwise/main.py',
                console = 'integratedTerminal',
                cwd = '${workspaceFolder}',
            })
            vim.keymap.set('n', '<leader>dc', require('dap').continue)
            vim.keymap.set('n', '<leader>dsi', require('dap').step_into)
            vim.keymap.set('n', '<leader>dsv', require('dap').step_over)
            vim.keymap.set('n', '<leader>dsu', require('dap').step_out)
            vim.keymap.set('n', '<leader>dsb', require('dap').step_back)
            vim.keymap.set('n', '<leader>dr', require('dap').restart)
            vim.keymap.set('n', '<leader>dui', require('dapui').toggle)

            require('dap').listeners.before.attach.dapui_config = function()
                require('dapui').open()
            end
            require('dap').listeners.before.launch.dapui_config = function()
                require('dapui').open()
            end
            require('dap').listeners.before.event_terminated.dapui_config = function()
                require('dapui').close()
            end
            require('dap').listeners.before.event_exited.dapui_config = function()
                require('dapui').close()
            end
        end,
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
        'yetone/avante.nvim',
        event = 'VeryLazy',
        build = 'make',
        opts = {
            file_selector = {
                provider = 'telescope',
            },
            hints = { enabled = false },
            debug = false,
            provider = 'claude',
            claude = {
                api_key_name = 'cmd:cat /home/denis/credentials/anthropic-api-key',
            },
            windows = {
                position = 'right', -- the position of the sidebar
                wrap = true, -- similar to vim.o.wrap
                width = 45, -- default % based on available width
                sidebar_header = {
                    align = 'right', -- left, center, right for title
                    rounded = true,
                },
            },
            behaviour = {
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                support_paste_from_clipboard = false,
            },
        },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'stevearc/dressing.nvim',
            'nvim-lua/plenary.nvim',
            'HakonHarnes/img-clip.nvim',
            {
                'grapp-dev/nui-components.nvim',
                dependencies = {
                    'MunifTanjim/nui.nvim',
                },
            },
        },
    },
    {
        'frankroeder/parrot.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('parrot').setup({
                toggle_target = 'buffer',
                providers = {
                    openai = {
                        api_key = read_file(
                            '/home/denis/credentials/openai-api-key'
                        ),
                    },
                    anthropic = {
                        api_key = read_file(
                            '/home/denis/credentials/anthropic-api-key'
                        ),
                    },
                },
                hooks = {
                    ChatFile = function(prt, params)
                        local chat_prompt = [[

          Given the following file:

          ```{{filetype}}
          {{filecontent}}
          ```

          Try to answer the questions to the best of your knowledge.
          ]]
                        prt.ChatNew(params, chat_prompt)
                    end,
                    CompleteFullContext = function(prt, params)
                        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{filecontent}}
        ```

        Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Finish the code above carefully and logically.
        Respond with only the snippet of code that should be inserted."
        ]]
                        local model_obj = prt.get_model('command')
                        prt.Prompt(
                            params,
                            prt.ui.Target.append,
                            model_obj,
                            nil,
                            template
                        )
                    end,
                },
            })
        end,
    },
    {
        'folke/which-key.nvim',
        opts = { icons = { mappings = false } },
    },
    { 'folke/neodev.nvim', opts = {} },
    -- { 'kylechui/nvim-surround', opts = {} },
    -- { 'echasnovski/mini.surround', opts = {} },
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
        lazy = false,
    },
    'mbbill/undotree',
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
    'APZelos/blamer.nvim',
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
        dependencies = 'nvim-tree/nvim-web-devicons',
        opts = {
            colors = {
                fg = '#ffffff',
            },
        },
    },
    {
        dir = '~/dotfiles/dennich',
        config = function()
            require('dennich.llm').setup({
                -- How long to wait for the request to start returning data.
                timeout_ms = 10000,
                services = {
                    -- Supported services configured by default
                    -- groq = {
                    --     url = "https://api.groq.com/openai/v1/chat/completions",
                    --     model = "llama3-70b-8192",
                    --     api_key_name = "GROQ_API_KEY",
                    -- },
                    -- openai = {
                    --     url = "https://api.openai.com/v1/chat/completions",
                    --     model = "gpt-4o",
                    --     api_key_name = "OPENAI_API_KEY",
                    -- },
                    anthropic = {
                        url = 'https://api.anthropic.com/v1/messages',
                        model = 'claude-3-5-sonnet-20240620',
                        api_key_name = 'ANTHROPIC_API_KEY',
                    },

                    -- Extra OpenAI-compatible services to add (optional)
                    -- other_provider = {
                    --     url = 'https://example.com/other-provider/v1/chat/completions',
                    --     model = 'llama3',
                    --     api_key_name = 'OTHER_PROVIDER_API_KEY',
                    -- },
                },
            })
        end,
    },
    -- Colors
    { 'folke/tokyonight.nvim', opts = { transparent = true } },
    { 'rebelot/kanagawa.nvim', opts = { transparent = true } },
    {
        -- local
        -- dir = '~/github.com/denismaciel/no-clown-fiesta.nvim',
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

            local open_in_nvim_tree = function(prompt_bufnr)
                local Path = require('plenary.path')

                local entry = action_state.get_selected_entry()[1]
                local entry_path = Path:new(entry):parent():absolute()
                actions.close(prompt_bufnr)
                entry_path = Path:new(entry):parent():absolute()
                entry_path = entry_path:gsub('\\', '\\\\')

                vim.cmd('NvimTreeClose')
                vim.cmd('NvimTreeOpen ' .. entry_path)

                local file_name = nil
                for s in string.gmatch(entry, '[^/]+') do
                    file_name = s
                end

                vim.cmd('/' .. file_name)
            end

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
                            ['<c-e>'] = open_in_nvim_tree,
                        },
                        i = {
                            ['<C-h>'] = actions_layout.toggle_preview,
                            ['<c-e>'] = open_in_nvim_tree,
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
        version = 'v0.*',
        opts = {
            keymap = {
                preset = 'default',
                -- ['<c-x>'] = {
                --     function(cmp)
                --         cmp.show({ providers = { 'minuet' } })
                --     end,
                -- },
            },
            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = 'mono',
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
                    -- minuet = {
                    --     name = 'minuet',
                    --     module = 'minuet.blink',
                    --     score_offset = 100,
                    -- },
                },
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
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            {
                'microsoft/python-type-stubs',
                -- cond = false makes sure the plugin is never loaded.
                -- It's not a real neovim plugin.
                -- We only need the data in the git repo for Pyright.
                cond = false,
            },
        },
        event = 'VeryLazy',
        config = function()
            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            -- local capabilities = vim.lsp.protocol.make_client_capabilities()

            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local lspconfig = require('lspconfig')
            local null_ls = require('null-ls')

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.diagnostics.cfn_lint,
                    null_ls.builtins.diagnostics.statix.with({
                        filetypes = { 'nix' },
                    }),
                    null_ls.builtins.formatting.golines,
                    null_ls.builtins.formatting.mdformat.with({
                        filetypes = { 'markdown' },
                    }),
                },
            })
            lspconfig.gopls.setup({
                capabilities = capabilities,
            })
            lspconfig.vtsls.setup({
                capabilities = capabilities,
            })
            lspconfig.terraformls.setup({
                capabilities = capabilities,
                filetypes = { 'terraform', 'hcl' },
            })
            lspconfig.biome.setup({
                capabilities = capabilities,
            })
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
                        diagnostics = {
                            globals = {
                                'vim',
                                'require',
                                'awesome', -- awesomewm
                                'client', -- awesomewm
                                'screen', -- awesomewm
                                'root', -- awesomewm
                            },
                        },
                    },
                },
            })
            lspconfig.jsonnet_ls.setup({
                capabilities = capabilities,
                ext_vars = {
                    foo = 'bar',
                },
                formatting = {
                    -- default values
                    Indent = 2,
                    MaxBlankLines = 2,
                    StringStyle = 'single',
                    CommentStyle = 'slash',
                    PrettyFieldNames = true,
                    PadArrays = false,
                    PadObjects = true,
                    SortImports = true,
                    UseImplicitPlus = true,
                    StripEverything = false,
                    StripComments = false,
                    StripAllButComments = false,
                },
            })
            lspconfig.cssls.setup({ capabilities = capabilities })
            lspconfig.pyright.setup({
                capabilities = capabilities,
                settings = {
                    python = {
                        stubPath = vim.fn.stdpath('data')
                            .. '/lazy/python-type-stubs',
                        exclude = {
                            'venv',
                            'venv-*',
                        },
                        analysis = {
                            autoSearchPaths = false,
                            useLibraryCodeForTypes = true,
                            -- typeCheckingMode = 'off',
                            -- diagnosticMode = 'workspace',
                            diagnosticMode = 'openFilesOnly',
                        },
                    },
                },
            })
            lspconfig.rust_analyzer.setup({ capabilities = capabilities })
            lspconfig.bashls.setup({ capabilities = capabilities })
            lspconfig.yamlls.setup({
                capabilities = capabilities,
                settings = {
                    yaml = {
                        schemaStore = {
                            enable = true,
                            url = 'https://www.schemastore.org/api/json/catalog.json',
                        },
                        keyOrdering = false,
                    },
                },
            })
            lspconfig.dockerls.setup({ capabilities = capabilities })
            lspconfig.cmake.setup({ capabilities = capabilities })
            lspconfig.bashls.setup({ capabilities = capabilities })
            lspconfig.tailwindcss.setup({ capabilities = capabilities })
            lspconfig.nil_ls.setup({
                capabilities = capabilities,
                settings = {
                    ['nil'] = {
                        formatting = {
                            command = { 'alejandra', '-qq' },
                        },
                    },
                },
            })
            lspconfig.hls.setup({ capabilities = capabilities })

            -- Autocommand for LSP.
            -- Key mpas should go in here.
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup(
                    'on-lsp-attach',
                    { clear = true }
                ),
                callback = function(event)
                    -- Rounded borders
                    local _border = 'rounded'
                    vim.lsp.handlers['textDocument/hover'] =
                        vim.lsp.with(vim.lsp.handlers.hover, {
                            border = _border,
                        })

                    vim.lsp.handlers['textDocument/signatureHelp'] =
                        vim.lsp.with(vim.lsp.handlers.signature_help, {
                            border = _border,
                        })

                    local map = function(keys, func, desc)
                        vim.keymap.set(
                            'n',
                            keys,
                            func,
                            { buffer = event.buf, desc = 'LSP: ' .. desc }
                        )
                    end

                    -- Stolen from https://github.com/tjdevries/config_manager/blob/ee11710c4ad09e0b303e5030b37c86ad8674f8b2/xdg_config/nvim/lua/tj/lsp/handlers.lua#L30
                    local implementation = function()
                        local params = vim.lsp.util.make_position_params()
                        vim.lsp.buf_request(
                            0,
                            'textDocument/implementation',
                            params,
                            function(err, result, ctx, config)
                                local bufnr = ctx.bufnr
                                local ft = vim.api.nvim_buf_get_option(
                                    bufnr,
                                    'filetype'
                                )

                                -- In go code, I do not like to see any mocks for impls
                                if ft == 'go' then
                                    local new_result = vim.tbl_filter(
                                        function(v)
                                            return not string.find(
                                                v.uri,
                                                '_mock'
                                            )
                                        end,
                                        result
                                    )

                                    if #new_result > 0 then
                                        result = new_result
                                    end
                                end

                                vim.lsp.handlers['textDocument/implementation'](
                                    err,
                                    result,
                                    ctx,
                                    config
                                )
                                vim.cmd([[normal! zz]])
                            end
                        )
                    end

                    -- map('gdd', vim.lsp.buf.declaration, 'Declaration')
                    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
                    vim.keymap.set('n', 'gD', implementation)
                    vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
                    vim.keymap.set('n', 'grn', vim.lsp.buf.rename)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover)
                    map('ga', vim.lsp.buf.code_action, 'Code action')
                    map('gr', function()
                        require('telescope.builtin').lsp_references(
                            require('telescope.themes').get_dropdown({})
                        )
                    end, 'References')
                end,
            })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-textobjects',
            'nvim-treesitter/playground',
        },
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                modules = {},
                sync_install = true,
                ignore_install = {},
                auto_install = true,
                ensure_installed = 'all',
                indent = {
                    enable = true,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        -- init_selection = '+',
                        -- node_incremental = '+',
                        -- node_decremental = '-',
                        init_selection = '<CR>',
                        scope_incremental = '<CR>',
                        node_incremental = '<TAB>',
                        node_decremental = '<S-TAB>',
                    },
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                    custom_captures = {
                        ['text.title.1'] = 'ErrorMsg',
                        ['_h1'] = '_h1',
                        ['h2'] = 'h2',
                        ['_h2'] = '_h2',
                        ['h3'] = 'h3',
                        ['_h3'] = '_h3',
                        ['h4'] = 'h4',
                        ['_h4'] = '_h4',
                        ['h5'] = 'h5',
                        ['_h5'] = '_h5',
                    },
                },
                textobjects = {
                    move = {
                        enable = true,
                        set_jumps = false, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            -- ["<C-n>"] = "@function.outer",
                            [']]'] = '@class.outer',
                            [']a'] = '@parameter.inner',
                        },
                        goto_previous_start = {
                            -- ["<C-p>"] = "@function.outer",
                            ['[['] = '@class.outer',
                            ['[a'] = '@parameter.inner',
                        },
                        goto_next_end = {
                            [']M'] = '@function.outer',
                            [']['] = '@class.outer',
                        },
                        goto_previous_end = {
                            ['[M'] = '@function.outer',
                            ['[]'] = '@class.outer',
                        },
                    },
                    select = {
                        enable = true,
                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = false,
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = '@class.inner',
                            ['ib'] = '@block.inner',
                            ['ab'] = '@block.outer',
                            ['as'] = '@statment.outer',
                            ['ia'] = '@assignment.inner',
                            ['aa'] = '@assignment.outer',
                        },
                    },
                },
            })
        end,
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
})

require('dennich.config')

vim.keymap.set({ 'n', 't' }, '<c-a>', function()
    Snacks.terminal.toggle()
end)

vim.keymap.set('n', '<leader>g,', function()
    require('dennich.llm').prompt({
        replace = false,
        service = 'anthropic',
    })
end, { desc = 'Prompt with openai' })
vim.keymap.set('v', '<leader>g,', function()
    require('dennich.llm').prompt({
        replace = false,
        service = 'anthropic',
    })
end, { desc = 'Prompt with openai' })
vim.keymap.set('v', '<leader>g.', function()
    require('dennich.llm').prompt({ replace = true, service = 'anthropic' })
end, { desc = 'Prompt while replacing with openai' })
