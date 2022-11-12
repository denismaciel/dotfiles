vim.g.python3_host_prog = os.getenv("HOME") .. '/venvs/neovim/bin/python'

o = vim.opt
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


require("plugins")
require("vim-gutentags")
require("lsp")
require("treesitter")
require("telescope-config")
require("nvim-tree-config")
require("dap-config")
require("cmp-config")
require("nvim-autopairs").setup({})
require("colors-config")
require("nvim-formatter-config")
require("mappings-config")
require("auto-save-config")
