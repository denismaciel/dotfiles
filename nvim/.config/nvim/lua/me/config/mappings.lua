local wk = require("which-key")
local sql = require("me.sql")
local zettel = require("me.zettel")
local themes = require("telescope.themes")

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
vim.keymap.set("v", "<leader>tm", ":!pandoc --to html | xclip -t text/html -selection clipboard<cr>u")

vim.keymap.set("n", "$", "g$")
vim.keymap.set("n", "0", "g0")
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "gp", "`[v`]")

-- https://stackoverflow.com/questions/290465/how-to-paste-over-without-overwriting-register
vim.keymap.set("x", "p", "pgvy")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "//", [[ y/\V<C-R>=escape(@",'/\')<CR><CR> ]]) --- Search currenlty selected text

vim.cmd("command Bd bp | sp | bn | bd")
vim.cmd("command Bdd bp! | sp! | bn! | bd!")

wk.setup({})
wk.register({
	f = {
		name = "File",
		c = { ":!echo -n % | xclip -selection clipboard<CR>", "Copy file path to clipboard" },
		f = { vim.lsp.buf.format, "Format current buffer" },
		n = { ":call RenameFile()<CR>", "Rename file" },
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
	t = {
		name = "Date",
		ss = { [["=strftime('%Y-%m-%d %H:%M')<CR>p]], "Instert current datetime" },
		sd = { [["=strftime('%Y-%m-%d')<CR>p]], "Insert current time" },
	},
	u = {
		function()
			vim.cmd("UndotreeShow")
		end,
		"Undotree",
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
			require("telescope.builtin").tags(themes.get_dropdown({
				shorten_path = true,
				layout_config = {
					width = function(_, max_columns)
						local percentage = 0.95
						return math.floor(percentage * max_columns)
					end,
					height = function(_, _, max_lines)
						local percentage = 0.9
						local min = 0
						return math.max(math.floor(percentage * max_lines), min)
					end,
				},
			}))
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
