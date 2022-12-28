require("lazy").setup({
	"folke/which-key.nvim",
	"folke/neodev.nvim",

	"jose-elias-alvarez/null-ls.nvim",

	"lewis6991/gitsigns.nvim",
	"TimUntersberger/neogit",
	"simrat39/symbols-outline.nvim",
	"windwp/nvim-autopairs",

	-- === DAP ===
	"mfussenegger/nvim-dap",
	"rcarriga/nvim-dap-ui",
	"leoluz/nvim-dap-go",
	"mfussenegger/nvim-dap-python",
	"nvim-telescope/telescope-dap.nvim",
	-- ===========

	"benfowler/telescope-luasnip.nvim",
	"NvChad/nvim-colorizer.lua",
	"klen/nvim-test",
	"ggandor/leap.nvim",
	"wbthomason/packer.nvim",
	"nvim-treesitter/nvim-treesitter-context",
	"christoomey/vim-tmux-navigator",
	"nvim-lua/plenary.nvim",
	{ "nvim-telescope/telescope.nvim", dependencies = { { "nvim-lua/plenary.nvim" } } },
	"tpope/vim-commentary",
	"editorconfig/editorconfig-vim",
	"mbbill/undotree",
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"nvim-treesitter/playground",
	"nvim-treesitter/nvim-treesitter-textobjects",
	"windwp/nvim-autopairs",
	"windwp/nvim-ts-autotag",
	"APZelos/blamer.nvim",
	"ludovicchabant/vim-gutentags",
	{
		"kyazdani42/nvim-tree.lua",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		version = "nightly",
	},
	"mhartington/formatter.nvim",

	-- == LSP ===
	"neovim/nvim-lspconfig",
	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({
				colors = {
					fg = "#666666",
				},
			})
		end,
	},
	"simrat39/inlay-hints.nvim",
	"williamboman/mason.nvim",
	"jayp0521/mason-nvim-dap.nvim",
	"williamboman/mason-lspconfig.nvim",

	-- === Completion ===
	"hrsh7th/vim-vsnip",
	"hrsh7th/vim-vsnip-integ",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp-signature-help",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"onsails/lspkind.nvim",

	-- === Colors ===
	"folke/tokyonight.nvim",
	"morhetz/gruvbox",
	"savq/melange",
	"rebelot/kanagawa.nvim",
	"shaunsingh/nord.nvim",
	"projekt0n/github-nvim-theme",
	"aktersnurra/no-clown-fiesta.nvim",
	"nyoom-engineering/oxocarbon.nvim",
})
