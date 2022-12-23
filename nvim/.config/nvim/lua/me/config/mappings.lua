local dap = require("dap")
-- local dapui = require("dapui")
local dap_go = require("dap-go")
local dappy = require("dap-python")
local wk = require("which-key")

local sql = require("me.sql")
local zettel = require("me.zettel")

vim.keymap.set("n", "<leader>asdf", function()
	package.loaded["me"] = nil
	vim.api.nvim_command([[ source $MYVIMRC ]])
end)
vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.implementation)
vim.keymap.set("n", "gtd", vim.lsp.buf.type_definition)
vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>;", "<cmd>Telescope buffers<CR>")
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "tre", "<cmd>NvimTreeToggle<CR>")

wk.setup({})
wk.register({
	f = {
		name = "File",
		c = { ":!echo -n % | xclip -selection clipboard<CR>", "Copy file path to clipboard" },
		f = { ":Format<CR>", "Format current buffer" },
		ls = { vim.lsp.buf.format, "Format with LSP" },
		n = { ":call RenameFile()<CR>", "Rename file" },
	},
	d = {
		name = "Date or DAP",
		-- Date
		s = { [["=strftime('%Y-%m-%d %H:%M')<CR>p]], "Instert current datetime" },
		d = { [["=strftime('%Y-%m-%d')<CR>p]], "Insert current time" },
		-- DAP
		c = { dap.continue, "DAP Continue" },
		b = { dap.toggle_breakpoint, "DAP Breakpoint Toggle" },
		B = {
			function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end,
			"DAP Breakpoint with Message",
		},
		t = {
			function()
				local ft = vim.bo.filetype
				if ft == "python" then
					dappy.test_method()
				elseif ft == "go" then
					dap_go.debug_test()
				else
					print("unkown file type", ft)
				end
			end,
			"DAP (Go) Debug Test",
		},
		i = { dap.step_into, "DAP Step Into" },
		o = { dap.step_out, "DAP Step Out" },
		v = { dap.step_over, "DAP Step Over" },
	},
	x = {
		name = "Trouble",
		x = { "<cmd>TroubleToggle<cr>", "Toggle" },
		w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
		d = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
		l = { "<cmd>TroubleToggle loclist<cr>", "Loclist" },
		q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix" },
		k = { vim.diagnostic.open_float, "Floating Diagnostics" },
	},
	s = {
		name = "SQL",
		s = { ":!sqly snapshot --file % --cte-name <cword> <CR>", "Snapshot CTE" },
		x = { sql.dbt_open_compiled, "Open compiled query" },
		v = { sql.dbt_open_snaps, "Open snapshots" },
	},
	z = {
		name = "Zettelkasten",
		n = { zettel.create_new_note, "New note" },
		a = { zettel.open_anki_note, "Anki note" },
	},
}, { prefix = "<leader>" })

wk.register({
	dd = {
		vim.lsp.buf.declaration,
		"!! Declaration",
	},
	a = {
		vim.lsp.buf.code_action,
		"Code action",
	},
	tt = {
		function()
			-- require("telescope.builtin").tags(require("telescope.themes").get_dropdown({
			-- 	width = function(_, _, max_lines)
			-- 		return math.min(max_lines * 0.5, 100)
			-- 	end,
			-- height = .8
			-- }))

			require("telescope.builtin").tags({ shorten_path = true })
		end,
		"!! Tags",
	},
	r = {
		function()
			require("telescope.builtin").lsp_references(require("telescope.themes").get_dropdown({}))
		end,

		"!! References",
	},
}, { prefix = "g" })

wk.register({
	name = "Telescope",
	t = {
		function()
			require("telescope.builtin").find_files({
				find_command = { "rg", "--files", "--hidden", "-g", "!.git", "-g", "!.snapshots/" },
				shorten_path = true,
			})

			-- require("telescope").extensions.frecency.frecency({
			-- 	find_command = { "rg", "--files", "--hidden", "-g", "!.git", "-g", "!.snapshots/" },
			-- 	workspace = "CWD",
			-- })
		end,
		"Find files",
	},
	d = {
		function()
			require("telescope.builtin").find_files({ find_command = { "git", "diff", "--name-only", "--relative" } })
		end,
		"Find diff files",
	},
	c = {
		require("telescope.builtin").comands,
		"Vim Commands",
	},
	h = {
		require("telescope.builtin").command_history,
		"Vim Comand History",
	},
	ft = {
		require("telescope.builtin").filetypes,
		"FileTypes",
	},
}, { prefix = "t" })

vim.keymap.set("n", "<leader>rg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>/", function()
	vim.cmd("Telescope treesitter")
end)
