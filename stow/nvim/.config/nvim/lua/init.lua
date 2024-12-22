-- vim.g.python3_host_prog = os.getenv('HOME') .. '/venvs/neovim/bin/python'

vim.g.mapleader = ' '

local o = vim.opt
-- o.foldmethod = "expr"
-- o.foldexpr = "nvim_treesitter#foldexpr()"

o.signcolumn = 'yes'
o.clipboard = 'unnamedplus'
o.formatoptions = o.formatoptions + 'cro'
o.mouse = 'a'
o.tabstop = 4 -- how many spaces a tab is when vim reads a file
o.softtabstop = 4 --how many spaces are inserted when you hit tab
o.shiftwidth = 4
o.autoindent = true
o.expandtab = true
o.hidden = true -- switch buffers without saving
o.wrap = false
o.number = false
o.termguicolors = true
o.backspace = { 'indent', 'eol', 'start' }
o.showcmd = false -- show command in bottom bar
o.showmatch = true -- highlight matching parenthesis

o.backup = false
o.swapfile = false
o.wrap = false

-- Search
o.incsearch = true -- search as characters are entered
o.hlsearch = true -- highlight matches
o.ignorecase = true
o.smartcase = true
o.scrolloff = 10 -- keep X lines above and below the cusrsor when scrolling

-- o.cursorline = true
-- o.cursorlineopt = 'number'

o.undodir = os.getenv('HOME') .. '/.config/nvim/undodir'

-- Decrease update time
o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
o.timeoutlen = 300

o.list = true
o.listchars = {
    tab = '▸ ',
    trail = '·',
    nbsp = '␣',
    extends = '❯',
    precedes = '❮',
}
o.fillchars = { eob = ' ' } -- hide ~ at end of buffer

o.undofile = true
o.showmatch = true

o.splitbelow = true
o.splitright = true

o.completeopt = { 'menu', 'menuone', 'noselect' }

o.laststatus = 3
-- o.winbar = '%=%m %f'
o.showmode = false
o.ruler = false
o.showcmd = false

vim.cmd('cabbrev W w')
vim.cmd('cabbrev Wq wq')
vim.cmd('cabbrev WQ wq')
vim.cmd('cabbrev bd Bd')
vim.cmd('cabbrev bd! Bdd')
vim.cmd('cabbrev Bd! Bdd')

vim.cmd([[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=200}
augroup END
]])

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '•',
            [vim.diagnostic.severity.WARN] = '•',
            [vim.diagnostic.severity.HINT] = '•',
            [vim.diagnostic.severity.INFO] = '•',
            ['DapBreakpoint'] = '•',
        },
    },
})

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
    'echasnovski/mini.base16',
    {
        'milanglacier/minuet-ai.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        -- config = function()
        --     require('minuet').setup({
        --         -- Your configuration options here
        --     })
        -- end,
    },
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
            local dap = require('dap')
            local ui = require('dapui')

            require('dap-python').setup('uv')
            require('dapui').setup()
            require('dap-go').setup()

            -- Node.js
            require('dap').adapters['pwa-node'] = {
                type = 'server',
                host = 'localhost',
                port = '${port}',
                executable = {
                    -- command = 'js-debug',
                    command = 'node',
                    args = {
                        '/nix/store/xpfrkzcwyrgr8g7q10c6zhaqmkjyxwgn-vscode-js-debug-1.95.3/lib/node_modules/js-debug/dist/src/dapDebugServer.js',
                        -- '/path/to/js-debug/src/dapDebugServer.js',
                        '${port}',
                    },
                },
            }

            for _, language in ipairs({ 'typescript', 'javascript' }) do
                require('dap').configurations[language] = {
                    {
                        name = 'Next.js: debug server-side',
                        type = 'pwa-node',
                        request = 'launch',
                        command = 'npm run dev',
                    },
                    {
                        name = 'Next.js: debug client-side',
                        type = 'chrome',
                        request = 'launch',
                        url = 'http://localhost:3000',
                    },
                    {
                        name = 'Next.js: debug client-side (Firefox)',
                        type = 'firefox',
                        request = 'launch',
                        url = 'http://localhost:3000',
                        reAttach = true,
                        pathMappings = {
                            {
                                url = 'webpack://_N_E',
                                path = '${workspaceFolder}',
                            },
                        },
                    },
                    {
                        name = 'Next.js: debug full stack',
                        type = 'node',
                        request = 'launch',
                        program = '${workspaceFolder}/node_modules/.bin/next',
                        runtimeArgs = { '--inspect' },
                        skipFiles = { '<node_internals>/**' },
                        serverReadyAction = {
                            action = 'debugWithEdge',
                            killOnServerStop = true,
                            pattern = '- Local:.+(https?://.+)',
                            uriFormat = '%s',
                            webRoot = '${workspaceFolder}',
                        },
                    },
                }
            end

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
                dap.toggle_breakpoint,
                { desc = '[dap] toogle breakpoint' }
            )
            vim.keymap.set(
                'n',
                '<space>dgb',
                dap.run_to_cursor,
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
            vim.keymap.set('n', '<leader>dc', dap.continue)
            vim.keymap.set('n', '<leader>dsi', dap.step_into)
            vim.keymap.set('n', '<leader>dsv', dap.step_over)
            vim.keymap.set('n', '<leader>dsu', dap.step_out)
            vim.keymap.set('n', '<leader>dsb', dap.step_back)
            vim.keymap.set('n', '<leader>dr', dap.restart)
            vim.keymap.set('n', '<leader>dui', ui.toggle)

            dap.listeners.before.attach.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                ui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                ui.close()
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
                    align = 'center', -- left, center, right for title
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
        dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
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
    { 'kylechui/nvim-surround', opts = {} },
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
            require('leap').set_default_keymaps()
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
    -- Colors
    'folke/tokyonight.nvim',

    'rebelot/kanagawa.nvim',

    { dir = '~/dotfiles/dennich' },
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

                    vim.diagnostic.config({
                        float = { border = _border },
                    })

                    local map = function(keys, func, desc)
                        vim.keymap.set(
                            'n',
                            keys,
                            func,
                            { buffer = event.buf, desc = 'LSP: ' .. desc }
                        )
                    end
                    map('gdd', vim.lsp.buf.declaration, 'Declaration')
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

vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('CustomizeWebDev', { clear = true }),
    pattern = { '*.js', '*.jsx', '*.ts', '*.tsx', '*.html', '*.css', '*.scss' },
    callback = function()
        vim.api.nvim_buf_set_option(0, 'shiftwidth', 2)
    end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup('CustomizeEnv', { clear = true }),
    pattern = { '.env.*', '*.env' },
    callback = function()
        vim.bo.filetype = 'sh'
        vim.lsp.buf_detach_client(0, 1) -- 0: current buffer, 1: bash clients (the only lsp running)
    end,
})

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        local file_path = vim.fn.expand('%:p')
        if file_path == '/tmp/tmux_pane_content' then
            vim.cmd('colorscheme tokyonight')
        end
    end,
})

-- vim.cmd([[ colorscheme no-clown-fiesta ]])

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local create_import_from_file_path = function(file_path)
    local parts = vim.fn.split(file_path, '/')
    local src_index = vim.fn.index(parts, 'src')
    if src_index == -1 then
        error('Error: \'src\' directory not found in the file path.')
        return
    end

    -- Find the index of 'src' in the table and remove every element before
    -- 'src' including 'src' itself.
    for i = 1, #parts do
        if parts[i] == 'src' then
            for _ = 1, i do
                table.remove(parts, 1)
            end
            break
        end
    end

    -- remove .py
    parts[#parts] = string.gsub(parts[#parts], '.py', '')

    local import_path = table.concat(parts, '.')
    local statement = string.format('from %s import ', import_path)
    return statement
end

local create_python_import_symbol = function()
    local current_file = vim.fn.expand('%:p')
    local statement = create_import_from_file_path(current_file)
    local cword = vim.fn.expand('<cword>')
    local out = statement .. cword
    print('Copying to clipboard: ' .. out)
    vim.fn.setreg('+', out)
end

local create_python_import_file = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection == nil then
        error('No file selected')
        return
    end

    local out = create_import_from_file_path(selection.value)
    vim.fn.setreg('+', out)
    -- Close the Telescope window
    actions.close(prompt_bufnr)
    print('statement avilable in the clipboard: ' .. out)
end

vim.keymap.set({ 'n' }, '<leader>is', create_python_import_symbol)
vim.keymap.set({ 'n' }, '<leader>if', function()
    require('telescope.builtin').find_files({
        attach_mappings = function(_, map)
            map('i', '<cr>', create_python_import_file)
            return true
        end,
    })
end, { desc = 'Python import statement' })

vim.keymap.set('n', '<leader>xl', ':.lua<cr>')
vim.keymap.set('v', '<leader>xl', ':lua<cr>')

local sql = require('dennich.sql')
local dennich = require('dennich')

-- Stolen from https://github.com/tjdevries/config_manager/blob/ee11710c4ad09e0b303e5030b37c86ad8674f8b2/xdg_config/nvim/lua/tj/lsp/handlers.lua#L30
local implementation = function()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(
        0,
        'textDocument/implementation',
        params,
        function(err, result, ctx, config)
            local bufnr = ctx.bufnr
            local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

            -- In go code, I do not like to see any mocks for impls
            if ft == 'go' then
                local new_result = vim.tbl_filter(function(v)
                    return not string.find(v.uri, '_mock')
                end, result)

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

vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', implementation)
vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
vim.keymap.set('n', 'grn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>;', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeFindFileToggle<CR>')

vim.keymap.set('n', 'gtt', function()
    local opts = require('telescope.themes').get_dropdown({
        layout_strategy = 'vertical',
        border = true,
        fname_width = 90,
        layout_config = {
            prompt_position = 'bottom',
            preview_cutoff = 10,
            width = function(_, max_columns, _)
                return max_columns - 10
            end,
            height = function(_, _, max_lines)
                return max_lines - 10
            end,
        },
    })
    opts.ctags_file = vim.fn.getcwd() .. '/tags'
    require('telescope.builtin').tags(opts)
end, { desc = 'Tags' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '$', 'g$')
vim.keymap.set('n', '<c>o', '<c>ozz')
vim.keymap.set('n', '<c>]', '<c>]zz')
vim.keymap.set('n', '0', 'g0')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'gp', '`[v`]')
vim.keymap.set('x', 'p', 'pgvy') -- https://stackoverflow.com/questions/290465/how-to-paste-over-without-overwriting-register
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '//', [[ y/\V<C-R>=escape(@",'/\')<CR><CR> ]]) --- Search currenlty selected text
vim.cmd('command Bd bp | sp | bn | bd')
vim.cmd('command Bdd bp! | sp! | bn! | bd!')

vim.keymap.set(
    'n',
    '<leader>fc',
    require('dennich').copy_file_path_to_clipboard,
    { desc = 'Copy file path to clipboard' }
)
vim.keymap.set('n', '<leader>ff', function()
    vim.lsp.buf.format()
    require('conform').format()
end, { desc = 'Format current buffer' })
vim.keymap.set(
    'n',
    '<leader>xx',
    '<cmd>Trouble diagnostics toggle<cr>',
    { desc = 'Diagnostics (Trouble)' }
)
vim.keymap.set(
    'n',
    '<leader>xd',
    '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    { desc = 'Document Diagnostics' }
)
vim.keymap.set(
    'n',
    '<leader>xk',
    vim.diagnostic.open_float,
    { desc = 'Line Diagnostics (floating)' }
)

vim.keymap.set(
    'n',
    '<leader>cs',
    '<cmd>Trouble symbols toggle focus=false<cr>',
    { desc = 'Symbols (Trouble)' }
)

vim.keymap.set(
    'n',
    '<leader>ss',
    ':!sqly snapshot --file % --cte-name <cword> <CR>',
    { desc = 'Snapshot CTE' }
)
vim.keymap.set(
    'n',
    '<leader>sx',
    sql.dbt_open_compiled,
    { desc = 'Open compiled query' }
)
vim.keymap.set('n', '<leader>sr', sql.dbt_open_run, { desc = 'Open run query' })
vim.keymap.set(
    'n',
    '<leader>sv',
    sql.dbt_open_snaps,
    { desc = 'Open snapshots' }
)
vim.keymap.set(
    'n',
    '<leader>sn',
    ':!echo -n %:t:r | xclip -selection clipboard<CR>',
    { desc = 'Copy model name to clipboard' }
)
vim.keymap.set('n', '<leader>st', function()
    require('telescope.builtin').find_files({
        find_command = {
            'rg',
            '--files',
            '--hidden',
            '-g',
            '!.git',
            '-g',
            '!.snapshots/',
        },
        cwd = '/home/denis/.cache/recap/bigquery-schema/',
    })
end, { desc = 'Find table schema' })

vim.keymap.set(
    'n',
    '<leader>tss',
    [["=strftime('%Y-%m-%d %H:%M')<CR>pI### <Esc>o<Enter>]],
    { desc = 'Insert current timestamp' }
)
vim.keymap.set(
    'n',
    '<leader>tsd',
    [["=strftime('%Y-%m-%d (%a)')<CR>p]],
    { desc = 'Insert current time' }
)
vim.keymap.set(
    'n',
    '<leader>u',
    '<cmd>UndotreeToggle<CR>',
    { desc = 'Undotree' }
)

vim.keymap.set({ 'n' }, '<leader>ao', function()
    dennich.find_anki_notes(require('telescope.themes').get_dropdown({}))
end, {
    desc = '[anki] find note',
})

vim.keymap.set({ 'n' }, '<leader>ae', function()
    dennich.anki_edit_note()
end, {
    desc = '[anki] edit note',
})

vim.keymap.set('n', 'tt', function()
    require('telescope.builtin').find_files({
        find_command = {
            'rg',
            '--files',
            '--hidden',
            '-g',
            '!.git',
            '-g',
            '!.snapshots/',
        },
    })
end, { desc = '[T]elescope Find Files' })
vim.keymap.set(
    'n',
    'td',
    dennich.insert_text,
    { desc = 'Insert block of text' }
)
vim.keymap.set(
    'n',
    'tc',
    require('telescope.builtin').commands,
    { desc = '[T]elescope Vim [C]ommands' }
)
vim.keymap.set(
    'n',
    'tch',
    require('telescope.builtin').command_history,
    { desc = '[T]elescope Vim [C]ommand [H]istory' }
)
vim.keymap.set(
    'n',
    'the',
    require('telescope.builtin').help_tags,
    { desc = '[T]elescope Vim [H][e]lp' }
)
vim.keymap.set(
    'n',
    'tft',
    require('telescope.builtin').filetypes,
    { desc = '[T]elescope [F]ile[T]ypes' }
)
vim.keymap.set(
    'n',
    'tm',
    require('telescope.builtin').marks,
    { desc = '[T]elescope [M]arks' }
)
vim.keymap.set(
    'n',
    'tb',
    require('telescope.builtin').current_buffer_fuzzy_find,
    { desc = '[T]elescope [B]uffers' }
)
vim.keymap.set(
    'n',
    '<leader>rg',
    require('telescope').extensions.egrepify.egrepify
)
vim.keymap.set('n', '<leader>/', require('telescope.builtin').treesitter)

vim.keymap.set('n', '<leader>o', function()
    local config_file = os.getenv('HOME') .. '/.config/nvim/lua/init.lua'
    vim.cmd('edit' .. config_file)
end)

local function open_test_file_go()
    local current_file_path = vim.fn.expand('%:p')
    current_file_path = string.gsub(current_file_path, vim.fn.getcwd(), '')
    local parts = vim.fn.split(current_file_path, '/')
    parts[#parts] = string.gsub(parts[#parts], '.go', '_test.go')

    local test_file_path = '.'
    for i = 1, #parts do
        test_file_path = test_file_path .. '/' .. parts[i]
    end

    vim.cmd('edit ' .. test_file_path)
end

local function open_test_file()
    local ft = vim.bo.filetype
    if ft == 'go' then
        open_test_file_go()
    elseif ft == 'python' then
        require('dennich').python_test_file()
    else
        print('No implementation for filetype: ' .. ft)
    end
end

vim.keymap.set('n', '<leader>ro', open_test_file)

local function open_parrot_code()
    vim.cmd('PrtWriteCode')
    vim.cmd('only')
end
vim.api.nvim_create_user_command('OpenParrot', open_parrot_code, {})

vim.keymap.set('n', '<leader>gn', '<cmd>PrtChatNew<cr>')
vim.keymap.set(
    'n',
    '<leader>gc',
    open_parrot_code,
    { noremap = true, silent = true, desc = 'PrtWriteCode' }
)
vim.keymap.set('n', '<leader>gf', '<cmd>PrtChatFile<cr>', {})
vim.keymap.set('n', '<leader>go', '<cmd>PrtCompleteFullContext<cr>', {})

local function run()
    print('run!')
end

vim.keymap.set('n', '<leader>rr', function()
    package.loaded['me'] = nil
    package.loaded['dennich'] = nil
    vim.api.nvim_command([[ source $MYVIMRC ]])
    print(require('dennich').copy_file_path_to_clipboard())
end)
