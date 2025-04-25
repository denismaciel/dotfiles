local M = {}
M.bigquery_check = function(env)
    local popen = io.popen

    local current_file = vim.fn.expand('%')
    local command = 'sqly type-check --env '
        .. env
        .. ' --query '
        .. current_file
    local pfile = popen(command)

    -- Put lines in a table
    local buff_lines = {}
    local i = 1
    if pfile == nil then
        print('No file found')
        return
    end
    for line in pfile:lines() do
        buff_lines[i] = line
        i = i + 1
    end
    print(buff_lines)
    local buffnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(buffnr, 0, 0, true, buff_lines)
    vim.cmd('split')
    vim.api.nvim_win_set_option(0, 'wrap', true)
    vim.api.nvim_win_set_buf(0, buffnr)
end

M.dbt_open_compiled = function()
    local fname = vim.fn.expand('%')
    local result =
        io.popen('./venv/bin/sqly get-dbt-compiled-path --file ' .. fname)
    if result == nil then
        print('No compiled file found')
        return
    end

    for line in result:lines() do
        vim.api.nvim_command('split')
        vim.api.nvim_command('view ' .. line)
        vim.api.nvim_command('syntax off')
        vim.treesitter.stop()
    end
end

M.dbt_open_run = function()
    local fname = vim.fn.expand('%')
    local result = io.popen('./venv/bin/sqly get-dbt-run-path --file ' .. fname)
    if result == nil then
        print('No run file found')
        return
    end
    for line in result:lines() do
        vim.api.nvim_command('split')
        vim.api.nvim_command('view ' .. line)
        vim.api.nvim_command('syntax off')
        vim.treesitter.stop()
    end
end

M.dbt_open_snaps = function()
    local root_folder = vim.fn.expand('%:h')
    local snap_folder_name = vim.fn.expand('%:t:r')
    local snap_folder_path = root_folder .. '/snaps/' .. snap_folder_name
    vim.api.nvim_command('vsplit ' .. snap_folder_path)
end

M.dbt_model_name = function()
    local snap_folder_name = vim.fn.expand('%:t:r')
    local command = [[ !echo ]]
        .. snap_folder_name
        .. [[ | xclip -selection clipboard ]]
    vim.cmd.execute(command)
end

M.dbt_set_keymaps = function()
    vim.keymap.set(
        'n',
        '<leader>ss',
        ':!sqly snapshot --file % --cte-name <cword> <CR>',
        { desc = '[dbt] snapshot CTE' }
    )
    vim.keymap.set(
        'n',
        '<leader>sx',
        M.dbt_open_compiled,
        { desc = '[dbt] open compiled query' }
    )
    vim.keymap.set(
        'n',
        '<leader>sr',
        M.dbt_open_run,
        { desc = '[dbt] open run query' }
    )
    vim.keymap.set(
        'n',
        '<leader>sv',
        M.dbt_open_snaps,
        { desc = '[dbt] open snapshots' }
    )

    vim.keymap.set(
        'n',
        '<leader>sn',
        ':!echo -n %:t:r | xclip -selection clipboard<CR>',
        { desc = '[dbt] copy model name to clipboard' }
    )
end

return M
