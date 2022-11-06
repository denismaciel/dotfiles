-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function()
	-- Candidate packages
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
		"rlch/github-notifications.nvim",
		-- config = [[require('config.github-notifications')]],
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
	})
	use("Pocco81/auto-save.nvim")

	--  Official packages
	use("ggandor/leap.nvim")
	use("wbthomason/packer.nvim")
	use("nvim-treesitter/nvim-treesitter-context")
	use("christoomey/vim-tmux-navigator")
	use("nvim-lua/plenary.nvim")
	use({ "nvim-telescope/telescope.nvim", requires = { { "nvim-lua/plenary.nvim" } } })
	use("tpope/vim-commentary")
	use("editorconfig/editorconfig-vim")
	use("mbbill/undotree")
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("windwp/nvim-autopairs")
	use("windwp/nvim-ts-autotag")
	use("APZelos/blamer.nvim")
	use("ludovicchabant/vim-gutentags")
	use("norcalli/nvim-colorizer.lua")
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons",
		},
		tag = "nightly",
	})
	use({ "mhartington/formatter.nvim" })
	-- == LSP ===
	use("neovim/nvim-lspconfig")
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({
				colors = {
					fg = "#666666",
				},
			})
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

	-- === Colors ===
	use("folke/tokyonight.nvim")
	use("morhetz/gruvbox")
	use("savq/melange")
	use("rebelot/kanagawa.nvim")
	use("shaunsingh/nord.nvim")
	use("projekt0n/github-nvim-theme")
	use("aktersnurra/no-clown-fiesta.nvim")

	require("leap").set_default_keymaps()
	require("nvim-tree").setup()
end)
