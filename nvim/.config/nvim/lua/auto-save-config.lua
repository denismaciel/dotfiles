require("auto-save").setup({
	enabled = true,
	execution_message = {
		message = function()
			return ""
		end,
	},
	trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save. See :h events
	condition = function(buf)
		local fn = vim.fn
		local utils = require("auto-save.utils.data")

		if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), { "go" }) then
			return true
		end
		return false
	end,
})
