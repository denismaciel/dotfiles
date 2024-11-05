local M = {}

local NOTES_FOLDER = '/home/denis/Sync/notes/'

M.sum = function(a, b)
    return a + b
end

M.is_url = function(text)
    if text == nil then
        return false
    end
    local url_pattern = '^https?://[%w-_%.%?%.:/%+=&;,@]+$'
    return string.match(text, url_pattern) ~= nil
end

M.create_weekly_note = function()
    -- Get current date information
    local current_time = os.time()
    local date_table = os.date('*t', current_time)

    -- Calculate the Monday of current week
    -- TODO: this is not Monday, but rather Sunday
    local days_since_monday = (date_table.wday + 6) % 7 -- Convert to Monday=0, Sunday=6
    local monday_timestamp = current_time - (days_since_monday * 24 * 60 * 60)
    local monday_date = os.date('%Y-%m-%d', monday_timestamp)

    local target_folder = NOTES_FOLDER .. 'current/private'

    local file_path_week = target_folder .. '/weekly/' .. monday_date .. '.md'

    -- Change to notes folder
    vim.fn.chdir(NOTES_FOLDER)

    -- Check if file exists, if not create it with header
    local file = io.open(file_path_week, 'r')
    if not file then
        file = io.open(file_path_week, 'w')
        if file then
            file:write('# ' .. monday_date)
            file:close()
        end
    else
        file:close()
    end

    -- Create daily note path and file
    local today_date = os.date('%Y-%m-%d', current_time)
    local file_path_day = target_folder .. '/daily/' .. today_date .. '.md'

    -- Check if daily file exists, if not create it with header
    local file_day = io.open(file_path_day, 'r')
    if not file_day then
        file_day = io.open(file_path_day, 'w')
        if file_day then
            file_day:write(
                '# ' .. today_date .. ' (' .. os.date('%A', current_time) .. ')'
            )
            file_day:close()
        end
    else
        file_day:close()
    end

    vim.cmd('edit ' .. vim.fn.fnameescape(file_path_week))
    -- short pause so that terminal can start and both splits will end up with the same size
    vim.cmd('vsplit ' .. vim.fn.fnameescape(file_path_day))

    -- Dirty fix: Schedule window equalization
    local async = require('plenary.async')
    async.run(function()
        async.util.sleep(50)
        vim.schedule(function()
            vim.cmd('wincmd =')
        end)
    end)
end

M.open_todo_note = function()
    vim.fn.chdir(NOTES_FOLDER)
    vim.cmd('edit todo.md')
end

return M
