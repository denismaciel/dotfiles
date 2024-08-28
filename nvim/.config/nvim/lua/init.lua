vim.g.python3_host_prog = os.getenv('HOME') .. '/venvs/neovim/bin/python'

vim.g.mapleader = ' '

local o = vim.opt

vim.cmd('set shortmess+=I')

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

vim.cmd([[
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
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
    -- {
    --     'yacineMTB/dingllm.nvim',
    --     dependencies = { 'nvim-lua/plenary.nvim' },
    --     config = function()
    --         local SYSTEM_PROMPT =
    --         'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
    --         local HELPFUL_PROMPT =
    --         'You are a helpful assistant. What I have sent are my notes so far.'
    --         local dingllm = require('dingllm')
    --
    --         local function anthropic_help()
    --             dingllm.invoke_llm_and_stream_into_editor(
    --                 {
    --                     url = 'https://api.anthropic.com/v1/messages',
    --                     model = 'claude-3-5-sonnet-20240620',
    --                     api_key_name = 'ANTHROPIC_API_KEY',
    --                     system_prompt = HELPFUL_PROMPT,
    --                     replace = false,
    --                 },
    --                 dingllm.make_anthropic_spec_curl_args,
    --                 dingllm.handle_anthropic_spec_data
    --             )
    --         end
    --
    --         local function anthropic_replace()
    --             dingllm.invoke_llm_and_stream_into_editor(
    --                 {
    --                     url = 'https://api.anthropic.com/v1/messages',
    --                     model = 'claude-3-5-sonnet-20240620',
    --                     api_key_name = 'ANTHROPIC_API_KEY',
    --                     system_prompt = SYSTEM_PROMPT,
    --                     replace = true,
    --                 },
    --                 dingllm.make_anthropic_spec_curl_args,
    --                 dingllm.handle_anthropic_spec_data
    --             )
    --         end
    --
    --         vim.keymap.set(
    --             { 'n', 'v' },
    --             '<leader>I',
    --             anthropic_help,
    --             { desc = 'llm anthropic_help' }
    --         )
    --         vim.keymap.set(
    --             { 'n', 'v' },
    --             '<leader>i',
    --             anthropic_replace,
    --             { desc = 'llm anthropic' }
    --         )
    --     end,
    -- },
    {
        'yetone/avante.nvim',
        event = 'VeryLazy',
        build = 'make lua51',
        opts = {
            provider = 'claude',
            claude = {
                api_key_name = 'cmd:cat /home/denis/credentials/anthropic-api-key',
            },
            -- add any opts here
        },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'stevearc/dressing.nvim',
            'nvim-lua/plenary.nvim',
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
            })
        end,
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
    { 'folke/which-key.nvim', opts = {} },
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
                width = 70,
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
    {
        -- local
        -- dir = '~/github.com/denismaciel/no-clown-fiesta.nvim',
        'aktersnurra/no-clown-fiesta.nvim',
        opts = {
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
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-path',
            'onsails/lspkind.nvim',
        },
        config = function()
            local cmp = require('cmp')
            local lspkind = require('lspkind')
            lspkind.init()

            cmp.setup({
                mapping = {
                    ['<C-u>'] = cmp.mapping(
                        cmp.mapping.scroll_docs(-4),
                        { 'i', 'c' }
                    ),
                    ['<C-d>'] = cmp.mapping(
                        cmp.mapping.scroll_docs(4),
                        { 'i', 'c' }
                    ),
                    ['<C-e>'] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),
                    ['<C-y>'] = cmp.mapping.confirm({ select = false }),
                    ['<C-n>'] = cmp.mapping({
                        i = function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            else
                                cmp.complete()
                            end
                        end,
                        c = cmp.mapping.select_next_item(),
                        s = cmp.mapping.select_next_item(),
                    }),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'nvim_lsp' },
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol_text', -- show only symbol annotations
                        maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        -- The function below will be called before any actual modifications from lspkind
                        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                        before = function(entry, vim_item)
                            return vim_item
                        end,
                    }),
                },
            })
        end,
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            {
                'microsoft/python-type-stubs',
                -- cond = false makes sure the plugin is never loaded.
                -- It's not a real neovim plugin.
                -- We only need the data in the git repo for Pyright.
                -- cond = false,
            },
        },
        event = 'VeryLazy',
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities(
                vim.lsp.protocol.make_client_capabilities()
            )
            local configs = require('lspconfig.configs')
            local lspc = require('lspconfig')
            local null_ls = require('null-ls')
            local util = require('lspconfig.util')

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.black.with({
                        args = {
                            '--stdin-filename',
                            '$FILENAME',
                            '--skip-string-normalization',
                            '--quiet',
                            '-',
                        },
                    }),
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = {
                            'css',
                            'html',
                            'javascript',
                            'javascriptreact',
                            'json',
                            'scss',
                            'toml',
                            'typescript',
                            'typescriptreact',
                            'vue',
                            'yaml',
                        },
                    }),
                    null_ls.builtins.diagnostics.cfn_lint,
                    null_ls.builtins.diagnostics.statix,
                    null_ls.builtins.formatting.golines,
                    null_ls.builtins.formatting.mdformat,
                },
            })
            configs.gopls = {
                default_config = {
                    cmd = { 'gopls' },
                    filetypes = { 'go', 'gomod' },
                    root_dir = function(fname)
                        return util.root_pattern('go.work')(fname)
                            or util.root_pattern('go.mod', '.git')(fname)
                    end,
                },
                docs = {
                    default_config = {
                        root_dir = [[root_pattern("go.mod", ".git")]],
                    },
                },
            }
            lspc.gopls.setup({
                capabilities = capabilities,
            })
            lspc.vtsls.setup({
                capabilities = capabilities,
            })
            lspc.terraformls.setup({
                capabilities = capabilities,
                filetypes = { 'terraform', 'hcl' },
            })
            lspc.biome.setup({
                capabilities = capabilities,
            })
            lspc.lua_ls.setup({
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
            lspc.jsonnet_ls.setup({
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
            lspc.cssls.setup({ capabilities = capabilities })
            lspc.pyright.setup({
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
            -- lspc.rnix.setup({ capabilities = capabilities })
            lspc.rust_analyzer.setup({ capabilities = capabilities })
            lspc.bashls.setup({ capabilities = capabilities })
            lspc.yamlls.setup({
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
            lspc.dockerls.setup({ capabilities = capabilities })
            lspc.cmake.setup({ capabilities = capabilities })
            lspc.bashls.setup({ capabilities = capabilities })
            lspc.tailwindcss.setup({ capabilities = capabilities })
            lspc.nil_ls.setup({
                capabilities = capabilities,
                settings = {
                    ['nil'] = {
                        formatting = {
                            command = { 'alejandra', '-qq' },
                        },
                    },
                },
            })
            lspc.hls.setup({ capabilities = capabilities })

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

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client =
                        vim.lsp.get_client_by_id(event.data.client_id)
                    if
                        client
                        and client.server_capabilities.documentHighlightProvider
                    then
                        vim.api.nvim_create_autocmd(
                            { 'CursorHold', 'CursorHoldI' },
                            {
                                buffer = event.buf,
                                callback = vim.lsp.buf.document_highlight,
                            }
                        )

                        vim.api.nvim_create_autocmd(
                            { 'CursorMoved', 'CursorMovedI' },
                            {
                                buffer = event.buf,
                                callback = vim.lsp.buf.clear_references,
                            }
                        )
                    end

                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if
                        client
                        and client.server_capabilities.inlayHintProvider
                        and vim.lsp.inlay_hint
                    then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(
                                0,
                                not vim.lsp.inlay_hint.is_enabled()
                            )
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })
        end,
    },
    {
        'Vigemus/iron.nvim',
        config = function()
            local iron = require('iron.core')
            iron.setup({
                config = {
                    -- Whether a repl should be discarded or not
                    scratch_repl = true,
                    -- Your repl definitions come here
                    repl_definition = {
                        sh = {
                            -- Can be a table or a function that
                            -- returns a table (see below)
                            command = { 'zsh' },
                        },
                        python = {
                            command = { 'ipython' },
                        },
                    },
                    -- How the repl window will be displayed
                    -- See below for more information
                    repl_open_cmd = require('iron.view').bottom(20),
                },
                -- Iron doesn't set keymaps by default anymore.
                -- You can set them here or manually add keymaps to the functions in iron.core
                keymaps = {
                    send_motion = '<space>sc',
                    visual_send = '<space>sc',
                    send_file = '<space>sf',
                    send_line = '<space>sl',
                    send_paragraph = '<space>sp',
                    send_until_cursor = '<space>su',
                    send_mark = '<space>sm',
                    mark_motion = '<space>mc',
                    mark_visual = '<space>mc',
                    remove_mark = '<space>md',
                    cr = '<space>s<cr>',
                    interrupt = '<space>s<space>',
                    exit = '<space>sq',
                    clear = '<space>cl',
                },
                -- If the highlight is on, you can change how it looks
                -- For the available options, check nvim_set_hl
                highlight = {
                    italic = true,
                },
                ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
            })
            vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
            vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
            vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
            vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
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
                refactor = {
                    highlight_definitions = {
                        enable = true,
                        clear_on_cursor_move = true,
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
            vim.g.gutentags_project_root =
                { 'package.json', 'go.mod', 'requirements.txt', '.git' }
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
require('me.config.mappings')
local palette = require('no-clown-fiesta.palette')

local augroup_highlight_todo = 'DennichHighlightTodo'
local highlight_group_done = 'DennichDONE'
vim.api.nvim_create_augroup(augroup_highlight_todo, { clear = true })
-- Autocommand to extend Neovim's syntax to match `TODO` and `DONE`
vim.api.nvim_create_autocmd({ 'WinEnter', 'VimEnter' }, {
    group = augroup_highlight_todo,
    pattern = '*',
    callback = function()
        vim.fn.matchadd(highlight_group_done, 'DONE', -1)
        -- `Todo` is a prexisting highlight group that we leverage to highlight
        -- `TODO`.
        -- For `DONE`, we create need a new highlight group and set the `strikethrough`
        vim.fn.matchadd('Todo', 'TODO', -1)
    end,
})
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    group = augroup_highlight_todo,
    callback = function()
        vim.api.nvim_set_hl(
            0,
            highlight_group_done,
            { strikethrough = true, fg = 'gray' }
        )
        vim.api.nvim_set_hl(0, 'Todo', { bold = true, fg = palette.roxo })
        vim.api.nvim_set_hl(0, 'CodeBlock', { bg = palette.accent })
    end,
})

vim.cmd('colorscheme no-clown-fiesta')

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

vim.cmd([[ colorscheme default ]])
