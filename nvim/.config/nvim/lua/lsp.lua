local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'

function OrgImports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

vim.api.nvim_command("au BufWritePre *.go lua OrgImports()")

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

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
require'lspconfig'.tsserver.setup{
    capabilities = capabilities
}
require'lspconfig'.jedi_language_server.setup{
    capabilities = capabilities
}
require'lspconfig'.pyright.setup{
    capabilities = capabilities
}
require'lspconfig'.gopls.setup{
    capabilities = capabilities
}
require'lspconfig'.rust_analyzer.setup{
    capabilities = capabilities
}
require'lspconfig'.terraformls.setup{
    filetypes = { 'terraform', 'hcl' },
}
require'lspconfig'.sumneko_lua.setup{}
require'lspconfig'.rnix.setup{
    capabilities = capabilities
}
