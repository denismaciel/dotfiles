local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'

configs.gopls = {
  default_config = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod' },
    root_dir = function(fname)
      return util.root_pattern 'go.work'(fname) or util.root_pattern('go.mod', '.git')(fname)
    end,
  },
  docs = {
    description = [[
https://github.com/golang/tools/tree/master/gopls
Google's lsp server for golang.
]],
    default_config = {
      root_dir = [[root_pattern("go.mod", ".git")]],
    },
  },
}

require'lspconfig'.tsserver.setup{on_attach=require'completion'.on_attach}
-- require'lspconfig'.jedi_language_server.setup{on_attach=require'completion'.on_attach}
require'lspconfig'.pyright.setup{on_attach=require'completion'.on_attach}
require'lspconfig'.gopls.setup{on_attach=require'completion'.on_attach}
