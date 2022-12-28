local awful = require("awful")

local M = {}

M.find_client_by_class = function(klass)
	for _, c in ipairs(client.get()) do
		if c.class == klass then
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

return M
