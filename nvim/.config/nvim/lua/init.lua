vim.g.python3_host_prog = os.getenv("HOME") .. "/venvs/neovim/bin/python"

local o = vim.opt
o.tabstop = 4 -- how many spaces a tab is when vim reads a file
o.softtabstop = 4 --how many spaces are inserted when you hit tab
o.shiftwidth = 4
o.autoindent = true
o.expandtab = true
o.hidden = true -- switch buffers without saving
o.wrap = false
o.number = true
o.termguicolors = true
o.backspace = { "indent", "eol", "start" }
o.showcmd = true -- show command in bottom bar
o.showmatch = true -- highlight matching parenthesis

o.backup = false
o.swapfile = false
o.wrap = false

-- Search
o.incsearch = true -- search as characters are entered
o.hlsearch = true -- highlight matches
o.ignorecase = true
o.smartcase = true

o.cursorline = true

o.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"

o.undofile = true
o.showmatch = true

o.splitbelow = true
o.splitright = true

o.completeopt = { "menu", "menuone", "noselect" }

o.termguicolors = true

-- Bootstrap lazy.nvim
vim.cmd([[
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
]])

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.fn.sign_define("DapBreakpoint", { text = "•", linehl = "", numhl = "" })

require("plugins")

require("neodev").setup() -- Needs to be called before lsp stuff
require("mason").setup()
require("nvim-autopairs").setup({})
require("colorizer").setup({})
require("neogit").setup()
require("gitsigns").setup()
require("nvim-test").setup({})
require("nvim-test.runners.pytest"):setup({
	command = { (vim.env.VIRTUAL_ENV or "venv") .. "/bin/pytest", "pytest" },
	args = { "--pdb" },
})

-- require("me.config.auto-save")
require("me.config.cmp")
require("me.config.colors")
-- require("me.config.copilot")
require("me.config.dap")
require("me.config.leap")
require("me.config.lsp")
require("me.config.mappings")
require("me.config.nvim-tree")
require("me.config.symbols-outline")
require("me.config.telescope")
require("me.config.treesitter")
require("me.config.vim-gutentags")
require("me.config.luasnip")
