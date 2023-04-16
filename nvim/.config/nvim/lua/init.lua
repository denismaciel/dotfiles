vim.g.python3_host_prog = os.getenv("HOME") .. "/venvs/neovim/bin/python"
vim.g.mapleader = " "

o = vim.opt

o.clipboard = o.clipboard + "unnamedplus"
o.formatoptions = o.formatoptions + "cro"
o.mouse = "a"
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

o.laststatus = 3
o.winbar = "%=%m %f"

vim.cmd("cabbrev W w")
vim.cmd("cabbrev Wq wq")
vim.cmd("cabbrev WQ wq")
vim.cmd("cabbrev bd Bd")
vim.cmd("cabbrev bd! Bdd")
vim.cmd("cabbrev Bd! Bdd")

vim.cmd([[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=200}
augroup END
]])

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

-- Bootstrap lazy.nvim
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
require("gitsigns").setup()
require("nvim-test").setup({})
-- require("nvim-test.runners.pytest"):setup({
-- 	command = { (vim.env.VIRTUAL_ENV or "venv") .. "/bin/pytest", "pytest" },
-- 	args = { "--pdb" },
-- })
require("nvim-surround").setup({})
require("hlargs").setup()
require("barbecue").setup()

require("me.config.cmp")
require("me.config.colors")
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

-- It seems these options need to be set *after* treesitter has been configured.
-- Otherwise, it will download all the parsers every time on startup.
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldlevelstart = 99
o.foldlevel = 99
