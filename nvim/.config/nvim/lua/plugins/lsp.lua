return {
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

        local custom_sources = require "me.null-ls"

        null_ls.setup({
            sources = {
                custom_sources.formatting.jsonnet,
                -- custom_sources.hover.man,
                null_ls.builtins.formatting.reorder_python_imports,
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
                null_ls.builtins.formatting.prettier,
                null_ls.builtins.diagnostics.cfn_lint,
                null_ls.builtins.diagnostics.statix,
                null_ls.builtins.formatting.golines,
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

        lspc.prismals.setup({
            capabilities = capabilities,
        })
        lspc.terraformls.setup({
            capabilities = capabilities,
            filetypes = { 'terraform', 'hcl' },
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
                            'client',  -- awesomewm
                            'screen',  -- awesomewm
                            'root',    -- awesomewm
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
        lspc.eslint.setup({ capabilities = capabilities })
        lspc.jedi_language_server.setup({ capabilities = capabilities })
        lspc.pyright.setup({
            -- capabilities = capabilities,
            -- autostart = false,
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
                        typeCheckingMode = 'off',
                        -- diagnosticMode = 'workspace',
                        diagnosticMode = 'openFilesOnly',
                    },
                },
            },
        })
        lspc.rnix.setup({ capabilities = capabilities })
        lspc.rust_analyzer.setup({ capabilities = capabilities })
        lspc.bashls.setup({ capabilities = capabilities })
        -- lspc.tsserver.setup({ capabilities = capabilities })
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
    end,
}
