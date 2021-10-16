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
    if buf_dir == '/home/denis/Sync/Notes/Current' then
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
        print('Not in notes directory, sucker. Current at '..buf_dir)
    end
end
