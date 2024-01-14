-- Script to interact with awesomewm
-- Usage:
--    awesome-client < test-awesome.lua
--
-- NOTE: print doesn't work as expected, that's why we override it to send a notification

naughty = require('naughty')

local print = function(text)
    naughty.notify({
        title = 'CLI Notification',
        text = text,
    })
end

-- Function to list all clients
local function list_clients()
    local clients = client.get() -- Fetches all clients

    for _, c in pairs(clients) do
        if c.name then
            print('Client Name: ' .. c.name .. ' ' .. c.class)
        end
    end
end

-- Call the function
list_clients()
