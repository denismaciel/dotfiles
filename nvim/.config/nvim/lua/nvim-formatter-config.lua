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
        yaml = {
            prettier
        },
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		python = {
			function()
			    return {
			        exe = "black",
			        args = { "-q", "--skip-string-normalization", "-"},
			        stdin = true,
			    }
			end,
			function()
				return {
					exe = "reorder-python-imports",
					args = { "-" },
					stdin = true,
                    ignore_exitcode = true,
				}
			end,
		},
		go = {
			require("formatter.filetypes.go").gofumpt,
		},
	},
})
