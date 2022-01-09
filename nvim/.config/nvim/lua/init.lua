
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
    -- if buf_dir == '/home/denis/Sync/Notes/Current' then
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

        vim.api.nvim_buf_delete(0, {force = false})
        vim.api.nvim_command('edit '..buf_dir..'/'..next_f)
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
