-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function()
	-- Candidate packages
	use("ggandor/leap.nvim")
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	})
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
	use("leoluz/nvim-dap-go")
	use("mfussenegger/nvim-dap-python")
	use({
		"klen/nvim-test",
		config = function()
			require("nvim-test").setup()
		end,
	})
	use({
		"xiyaowong/nvim-transparent",
		config = function()
			require("transparent").setup({
				enable = true, -- boolean: enable transparent
				extra_groups = { -- table/string: additional groups that should be cleared
					-- In particular, when you set it to 'all', that means all available groups

					-- example of akinsho/nvim-bufferline.lua
					"BufferLineTabClose",
					"BufferlineBufferSelected",
					"BufferLineFill",
					"BufferLineBackground",
					"BufferLineSeparator",
					"BufferLineIndicatorSelected",
				},
				exclude = {}, -- table: groups you don't want to clear
			})
		end,
	})

	--  Official packages
	use("wbthomason/packer.nvim")
	use("google/vim-jsonnet")
	use("nvim-treesitter/nvim-treesitter-context")
	use("christoomey/vim-tmux-navigator")
	use("nvim-lua/plenary.nvim")
	use({ "nvim-telescope/telescope.nvim", requires = { { "nvim-lua/plenary.nvim" } } })
	use({ "nvim-telescope/telescope-file-browser.nvim" })
	use("tpope/vim-commentary")
	use("editorconfig/editorconfig-vim")
	use("vimwiki/vimwiki")
	use("mbbill/undotree")
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("windwp/nvim-autopairs")
	use("windwp/nvim-ts-autotag")
	use("APZelos/blamer.nvim")
	use("ludovicchabant/vim-gutentags")
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons",
		},
		tag = "nightly",
	})
	-- == LSP ===
	use("neovim/nvim-lspconfig")
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	})
	-- === Completion ===
	use("hrsh7th/vim-vsnip")
	use("hrsh7th/vim-vsnip-integ")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	-- use '/home/denis/mine/dbt.nvim'
	use({ "mhartington/formatter.nvim" })

	-- === Colors ===
	use("rktjmp/lush.nvim")
	use("folke/tokyonight.nvim")
	use({
		"mcchrish/zenbones.nvim",
		requires = "rktjmp/lush.nvim",
	})
	use("morhetz/gruvbox")
	use("savq/melange")
	use("rebelot/kanagawa.nvim")
	use("shaunsingh/nord.nvim")

	require("leap").set_default_keymaps()
	require("nvim-tree").setup()
end)
