local function open_test_file()
    -- Opens the test file for the current file
    --
    -- Get relative path of the current file
    local current_file_path = vim.fn.expand('%:p')
    -- remove the root directory from the path
    current_file_path = string.gsub(current_file_path, vim.fn.getcwd(), '')

    local parts = vim.fn.split(current_file_path, '/')
    table.remove(parts, 1) -- remove src
    table.remove(parts, 1) -- remove pkg_name

    -- replace the file name with "_test.py"
    parts[#parts] = string.gsub(parts[#parts], '.py', '_test.py')

    -- create directory structure if it doesn't exist
    local test_file_path = './tests'
    for i = 1, #parts - 1 do
        test_file_path = test_file_path .. '/' .. parts[i]
        vim.fn.mkdir(test_file_path, 'p')
    end

    test_file_path = test_file_path .. '/' .. parts[#parts]
    vim.cmd('edit ' .. test_file_path)
end

return {
    {
        'nvim-neotest/neotest',
        keys = {
            {
                '<Leader>ro',
                function()
                    open_test_file()
                end,
                { noremap = true, silent = true },
            },
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
            require('neotest').setup({
                adapters = {
                    require('neotest-python')({
                        dap = { justMyCode = false },
                        pytest_discover_instances = true,
                    }),
                },
            })
        end,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'antoinemadec/FixCursorHold.nvim',
            'nvim-neotest/neotest-python',
        },
    },
}
