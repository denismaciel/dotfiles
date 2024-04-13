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
--
-- -- Function to list all clients
-- local function list_clients()
--     local clients = client.get() -- Fetches all clients
--
--     for _, c in pairs(clients) do
--         if c.name then
--             print('Client Name: ' .. c.name .. ' ' .. c.class)
--         end
--     end
-- end

-- Call the function
-- list_clients()

-- -- Function to minimize all clients except the currently active one
-- local function minimize_except_focused()
--     -- Get the currently focused client
--     local focused_client = client.focus
--
--     -- Iterate over all clients
--     for _, c in ipairs(client.get()) do
--         -- Check if the client is not the focused client
--         if c ~= focused_client then
--             -- Minimize the client
--             c.minimized = true
--         end
--     end
-- end
--
-- minimize_except_focused()

local awful = require('awful')
print(awful.client.name)
print(awful.client.class)
print(awful.client.focus.history.previous())
print(awful.client.name)
print(awful.client.class)
print('here')
