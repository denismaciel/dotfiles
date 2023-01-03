local actions = require("telescope.actions")

require("telescope").setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--hidden",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		file_ignore_patterns = {
			"%.eot",
			"%.ttf",
			"%.woff",
			"%.woff2",
		},
		layout_config = {
			width = function(_, max_columns)
				local percentage = 0.95
				return math.floor(percentage * max_columns)
			end,
			height = function(_, _, max_lines)
				local percentage = 0.9
				local min = 70
				return math.max(math.floor(percentage * max_lines), min)
			end,
		},
	},
	pickers = {
		buffers = {
			mappings = {
				n = {
					["dd"] = actions.delete_buffer,
				},
			},
		},
		tags = {
			mappings = {
				n = {
					["df"] = actions.send_selected_to_qflist + actions.open_qflist,
				},
			},
		},
	},
})

require("telescope").load_extension("luasnip")
