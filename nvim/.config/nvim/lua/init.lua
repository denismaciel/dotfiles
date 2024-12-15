vim.g.python3_host_prog = os.getenv('HOME') .. '/venvs/neovim/bin/python'

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
                -- auto_suggestions = true, -- Experimental stage
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                -- auto_apply_diff_after_generation = true,
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
                    WriteCode = function(prt, params)
                        local chat_prompt = [[
                        When writing code, return only the code.
                        Never explain the code unless explicitly asked.

                        Rules for Python code:

                        - You're writing Python 3.12.
                        - File-based operations should done using pathlib instead of os module.
                        - Always type-annotate your functions and methods.
                        - Your code will run against mypy in strict mode.
                        - When typing-annotating the code:
                            - use `list` instead of `typing.List`
                            - use `dict` instead of `typing.Dict`
                            - use `tuple` instead of `typing.Tuple`
                            - be as specific as possible with your typing.
                            - avoid using `typing.Any`
                            - always use specific and concrete type annotations rather than generic ones including nested types.
                              For example, use
                                - `dict[str, list[int\]\]` instead of `dict` or `dict[str, list]`,
                                - `list[float]` instead of just `list`,
                                -  `set[str]` instead of just `set`
                        - Use Pydantic BaseModel liberally.

                        Return only the code.
                        If anything other than code is returned a puppy dies.
                        An explanation can be returned without harm to puppies if explicitly asked for.
                        Take care of the puppies.
                        This is very important.

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
    -- {
    --     'NvChad/nvim-colorizer.lua',
    --     config = function()
    --         require('colorizer').setup({
    --             filetypes = {
    --                 'html',
    --                 'css',
    --                 'sass',
    --                 'scss',
    --                 'javascript',
    --                 'javascriptreact',
    --                 'typescript',
    --                 'typescriptreact',
    --                 'vue',
    --                 'svelte',
    --                 'lua',
    --             },
    --             user_default_options = {
    --                 mode = 'virtualtext',
    --                 names = false,
    --             },
    --         })
    --     end,
    -- },
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
                        maxwidth = 100, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
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
                -- cond = false,
            },
        },
        event = 'VeryLazy',
        config = function()
            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend(
                'force',
                capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            local lspc = require('lspconfig')
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
        vim.fn.matchadd(highlight_group_done, 'DONE.*', -1)
        -- `Todo` is a prexisting highlight group that we leverage to highlight
        -- `TODO`.
        -- For `DONE`, we need a new highlight group and set the `strikethrough`
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
        vim.api.nvim_set_hl(0, 'Todo', { bold = true })
        vim.api.nvim_set_hl(0, 'CodeBlock', { bg = palette.accent })
    end,
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

vim.cmd([[ colorscheme no-clown-fiesta ]])

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
