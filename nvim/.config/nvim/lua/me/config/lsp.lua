local lspc = require("lspconfig")
local configs = require("lspconfig/configs")
local util = require("lspconfig/util")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local null_ls = require("null-ls")

require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"rust_analyzer",
		"gopls",
		"tsserver",
		"prismals",
		"pyright",
		"tailwindcss",
	},
})

null_ls.setup({
	sources = {
		-- Python
		null_ls.builtins.formatting.reorder_python_imports,
		null_ls.builtins.formatting.black.with({
			args = { "--stdin-filename", "$FILENAME", "--skip-string-normalization", "--quiet", "-" },
		}),
		null_ls.builtins.formatting.ruff,
		-- Lua
		null_ls.builtins.formatting.stylua,
		-- Javascript
		null_ls.builtins.formatting.prettier,
		-- Cloudformation
		null_ls.builtins.diagnostics.cfn_lint,
	},
})

function OrgImports()
	local params = vim.lsp.util.make_range_params()
	params.context = { only = { "source.organizeImports" } }
	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, nil)
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

vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.go" }, callback = OrgImports })

configs.gopls = {
	default_config = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod" },
		root_dir = function(fname)
			return util.root_pattern("go.work")(fname) or util.root_pattern("go.mod", ".git")(fname)
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

lspc.terraformls.setup({
	capabilities = capabilities,
	filetypes = { "terraform", "hcl" },
})
lspc.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = {
				globals = { "vim", "require" },
			},
		},
	},
})
lspc.jsonnet_ls.setup({
	capabilities = capabilities,
	ext_vars = {
		foo = "bar",
	},
	formatting = {
		-- default values
		Indent = 2,
		MaxBlankLines = 2,
		StringStyle = "single",
		CommentStyle = "slash",
		PrettyFieldNames = true,
		PadArrays = false,
		PadObjects = true,
		SortImports = true,
		UseImplicitPlus = true,
		StripEverything = false,
		StripComments = false,
		StripAllButComments = false,
	},
})
lspc.cssls.setup({ capabilities = capabilities })
lspc.gopls.setup({ capabilities = capabilities })
lspc.jedi_language_server.setup({ capabilities = capabilities })
lspc.pyright.setup({ capabilities = capabilities })
lspc.rnix.setup({ capabilities = capabilities })
lspc.rust_analyzer.setup({ capabilities = capabilities })
lspc.tailwindcss.setup({ capabilities = capabilities })
lspc.tsserver.setup({ capabilities = capabilities })
lspc.yamlls.setup({ capabilities = capabilities })
lspc.dockerls.setup({ capabilities = capabilities })
lspc.cmake.setup({ capabilities = capabilities })
