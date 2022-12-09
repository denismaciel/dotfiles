vim.g.python3_host_prog = os.getenv("HOME") .. '/venvs/neovim/bin/python'

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

require("nvim-autopairs").setup({})

require("plugins")
require("me.config.vim-gutentags")
require("me.config.lsp")
require("me.config.treesitter")
require("me.config.telescope")
require("me.config.nvim-tree")
require("me.config.dap")
require("me.config.cmp")
require("me.config.colors")
require("me.config.nvim-formatter")
require("me.config.mappings")
require("me.config.auto-save")
require("me.config.leap")
