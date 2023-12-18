return {
    {
        'nvim-neotest/neotest',
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
                    require('neotest').jump.prev { status = 'failed' }
                end,
                { noremap = true, silent = true },
            },
            {
                ']n',
                function()
                    require('neotest').jump.next { status = 'failed' }
                end,
                { noremap = true, silent = true },
            },
        },
        config = function()
            require('neotest').setup {
                adapters = {
                    require 'neotest-python' {
                        dap = { justMyCode = false },
                        pytest_discover_instances = true,
                    },
                },
            }
        end,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'antoinemadec/FixCursorHold.nvim',
            'nvim-neotest/neotest-python',
        },
    },
}
