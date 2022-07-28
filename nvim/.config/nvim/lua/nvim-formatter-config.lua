local util = require("formatter.util")

prettier = require("formatter.filetypes.javascript").prettier

require("formatter").setup({
	logging = true,
	log_level = vim.log.levels.DEBUG,
	filetype = {
		javascript = {
			prettier,
		},
		typescript = {
			prettier,
		},
		typescriptreact = {
			prettier,
		},
		css = {
			prettier,
		},
		html = {
			prettier,
		},
		json = {
			prettier,
		},
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		python = {
			require("formatter.filetypes.python").black,
		},
		go = {
			require("formatter.filetypes.go").gofumpt,
		},
	},
})
