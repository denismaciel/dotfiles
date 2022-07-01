function bigquery_check(env) 
    local i, t, popen = 0, {}, io.popen

    current_file = vim.fn.expand('%')
    local command = 'sqly type-check --env ' .. env .. ' --query ' .. current_file
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
    local curbuf = vim.api.nvim_win_get_buf(0)     
    vim.api.nvim_win_set_option(0, 'wrap', true)
    vim.api.nvim_win_set_buf(0, buffnr)
end

function complete_todos() 
    local fname = vim.fn.expand('%')
    local todo_bf = 2
    local done_bf = 3

    if not string.match(fname, "todo.md")  then
        print("Invoke this function from todo.md")
        return 1
    end

    local pattern = 'DONE'
    local lines = vim.api.nvim_buf_get_lines(todo_bf, 0, -1, true)     
    print("* Completed tasks: ")
    for line_nr, value in pairs(lines) do
        if string.sub(value, 1, string.len(pattern)) == pattern then
            vim.api.nvim_buf_set_lines(done_bf, 0, 0, true, {value})
            vim.api.nvim_buf_set_lines(todo_bf, line_nr-1, line_nr, true, {""})
            print("  -> ", value)
        end
    end
    vim.cmd [[ sort u]]
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function cycle_notes(direction)
    local idx
    local buf_dir = vim.fn.expand('%:p:h')
    local f_name = vim.fn.expand('%:t')
    if true then
        local files = scandir(buf_dir)
        for i, f in pairs(files) do
           if f == f_name then
               idx = i
           end
        end

        if direction == 'up' then
            next_f = files[idx+1]
        elseif direction == 'down' then
            next_f = files[idx-1]
        else
            print('Unkown direction')
        end

        cbuf = vim.api.nvim_get_current_buf()
        vim.api.nvim_command('edit '..buf_dir..'/'..next_f)
        vim.api.nvim_buf_delete(cbuf, {force = false})
    else
        print('Not inside notes directory, sucker. Current at '..buf_dir)
    end
end

function get_current_commit_sha(directory)
    local i, t, popen = 0, {}, io.popen
    local result = popen('git -C "'..directory..'" '.."rev-parse HEAD")
    for line in result:lines() do
        return line
    end
end

function get_github_permalink() 
    local sha = get_current_commit_sha(vim.fn.getcwd())
    local linenr = vim.api.nvim_win_get_cursor(0)[1]
    local file = vim.fn.expand('%:p')

    local _, j = string.find(file, "core")

    -- We want to get rid of: `.../core{0,1,2}/`. That's why j + 3.
    file = file:sub(j + 3, nil)
    local permalink = ("https://github.com/recap-technologies/core/blob/"..sha.."/"..file.."#L"..linenr)
    vim.cmd("let @+ = '"..permalink.."'")
end

function breakpoint()
    local linenr = vim.api.nvim_win_get_cursor(0)[1]
    local file = vim.fn.expand('%')
    local file_with_line = (file..":"..linenr)
    vim.cmd("let @+ = '"..file_with_line.."'")
end

P = function(v)
    print(vim.inspect(v))
    return v
end

function dbt_open_compiled()
    fname = vim.fn.expand('%')
    local result = io.popen("./venv/bin/sqly get-dbt-compiled-path --file "..fname)
    for line in result:lines() do
        vim.api.nvim_command('vsplit')
        vim.api.nvim_command('view '..line)
        vim.api.nvim_command('setlocal syntax=OFF')
    end
end

function dbt_open_snaps()
    root_folder = vim.fn.expand('%:h')
    snap_folder_name = vim.fn.expand('%:t:r')
    snap_folder_path = root_folder..'/snaps/'..snap_folder_name
    vim.api.nvim_command('vsplit '..snap_folder_path)
end
