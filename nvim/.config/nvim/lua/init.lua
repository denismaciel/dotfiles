require("me")

o = vim.opt

o.expandtab = true
o.hidden = true -- switch buffers without saving
o.wrap = false
o.number = true
o.termguicolors = true

o.backup = false
o.swapfile = false
o.wrap = false

-- Search
o.incsearch = true -- search as characters are entered
o.hlsearch = true -- highlight matches
o.ignorecase = true
o.smartcase = true

o.cursorline = true

o.undodir = "~/.config/nvim/undodir"
o.undofile = true
o.showmatch = true

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
