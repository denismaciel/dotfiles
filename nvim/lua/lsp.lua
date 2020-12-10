require'lspconfig'.tsserver.setup{on_attach=require'completion'.on_attach}
require'lspconfig'.jedi_language_server.setup{on_attach=require'completion'.on_attach}
-- require'lspconfig'.pyls.setup{on_attach=require'completion'.on_attach}
