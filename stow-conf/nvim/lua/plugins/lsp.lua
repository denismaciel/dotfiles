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

return {

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
            -- By default, Neovim doesn't support everything that is in the LSP specification.
            -- When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            -- So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            -- local capabilities = vim.lsp.protocol.make_client_capabilities()
            --
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local lspconfig = require('lspconfig')
            local null_ls = require('null-ls')

            vim.lsp.enable('basedpyright')
            vim.lsp.enable('gopls')

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
}
