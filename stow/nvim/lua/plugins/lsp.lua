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
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format({
                        async = true,
                        lsp_format = 'fallback',
                    })
                end,
                mode = '',
                desc = 'Format buffer',
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'ruff_fix', 'ruff_format' },
                typescript = { 'biome' },
                typescriptreact = { 'biome' },
                javascript = { 'biome' },
                javascriptreact = { 'biome' },
                go = { 'golines' },
                markdown = { 'mdformat' },
                nix = { 'alejandra' },
            },
            formatters = {
                biome = {
                    cwd = function()
                        return '/home/denis'
                    end,
                },
                golines = {
                    append_args = { '-m', '120' },
                },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_format = 'fallback',
            },
        },
    },
    {
        'mfussenegger/nvim-lint',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            local lint = require('lint')

            lint.linters_by_ft = {
                cloudformation = { 'cfn_lint' },
                yaml = { 'cfn_lint' }, -- For CloudFormation YAML files
                nix = { 'statix' },
                python = { 'dmypy' }, -- Fast mypy daemon for Python type checking
            }
            -- Create autocommand to trigger linting
            vim.api.nvim_create_autocmd(
                { 'BufEnter', 'BufWritePost', 'InsertLeave' },
                {
                    callback = function()
                        require('lint').try_lint()
                    end,
                }
            )
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

            vim.lsp.enable('basedpyright')
            vim.lsp.enable('gopls')
            vim.lsp.enable('ty')
            vim.lsp.enable('tsgo')
            vim.lsp.enable('terraformls')
            vim.lsp.enable('vtsls')
            vim.lsp.enable('biome')
            vim.lsp.config('lua_lsl', {
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
            vim.lsp.enable('lua_ls')
            vim.lsp.enable('jsonnet_ls')
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

                    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
                    vim.keymap.set('n', 'gD', implementation)
                    vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover)
                    map('ga', vim.lsp.buf.code_action, 'Code action')
                    map('gr', vim.lsp.buf.references, 'References')
                end,
            })
        end,
    },
}
