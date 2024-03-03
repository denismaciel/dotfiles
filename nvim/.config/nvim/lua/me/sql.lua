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
    vim.print('here')
    local command = [[ !echo ]]
        .. snap_folder_name
        .. [[ | xclip -selection clipboard ]]
    vim.cmd.execute(command)
end

return M
