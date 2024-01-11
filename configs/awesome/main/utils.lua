local awful = require('awful')
local json = require('main.dkjson')

local M = {}

function debug_log(obj)
    local f = io.open('/tmp/awesome-debug.log', 'w')
    f:write(obj .. '\n')
    f:close()
end

M.find_client_by_class = function(klass)
    local clients_with_klass = {}
    for _, c in ipairs(client.get()) do
        if c.class == klass then
            table.insert(clients_with_klass, c)
        end
    end

    if #clients_with_klass == 0 then
        return nil
    elseif #clients_with_klass == 1 then
        return clients_with_klass[1]
    end

    -- If we have more than two cliens with the same class,
    -- we want to focus the first one that is not the current
    -- focused client, so we can cycle through them.
    -- NOTE: this work only if we have two clients with the same
    -- class.
    for _, c in ipairs(clients_with_klass) do
        if c ~= client.focus then
            return c
        end
    end
    return nil
end

M.focus_or_spawn = function(klass, spawn_command)
    local found = M.find_client_by_class(klass)

    if found ~= nil then
        client.focus = found
        found:raise()
    else
        awful.util.spawn(spawn_command)
    end
end

-- Read work mode from a JSON file
M.getenv = function(name)
    -- File ./config/dennich/dennich.json
    local f = io.open(os.getenv('HOME') .. '/.config/dennich/dennich.json', 'r')

    if f == nil then
        return nil
    end
    local content = f:read('*all')
    f:close()
    local data = json.decode(content)
    -- write the value to a temp file for testing
    local f2 = io.open('/tmp/awesome-dennich.json', 'w')
    if f2 == nil then
        return nil
    end
    f2:write(content)
    f2:close()
    print(data['work_mode'])
end

return M
