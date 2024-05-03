return {
    {
        'nvim-neotest/neotest',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'antoinemadec/FixCursorHold.nvim',
            -- 'nvim-neotest/neotest-python',
            'nvim-neotest/neotest-go',
        },
        keys = {
            {
                '<Leader>rt',
                function()
                    require('neotest').run.run()
                end,
                { noremap = true, silent = true },
            },
            {
                '<Leader>rs',
                function()
                    require('neotest').summary.open()
                end,
                { noremap = true, silent = true },
            },

            {
                '[n',
                function()
                    require('neotest').jump.prev({ status = 'failed' })
                end,
                { noremap = true, silent = true },
            },
            {
                ']n',
                function()
                    require('neotest').jump.next({ status = 'failed' })
                end,
                { noremap = true, silent = true },
            },
        },
        config = function()
            local neotest_ns = vim.api.nvim_create_namespace('neotest')
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message = diagnostic.message
                            :gsub('\n', ' ')
                            :gsub('\t', ' ')
                            :gsub('%s+', ' ')
                            :gsub('^%s+', '')
                        return message
                    end,
                },
            }, neotest_ns)
            require('neotest').setup({
                adapters = {
                    require('neotest-go'),
                },
            })
        end,
    },
}
