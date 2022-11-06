require("auto-save").setup({
	enabled = true,
	execution_message = {
		message = function() 
            return ""
		end,
	},
	trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save. See :h events
})
