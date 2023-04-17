require("lazy").setup({
	{
		"img-paste-devs/img-paste.vim",
	},
	{
		"epwalsh/obsidian.nvim",
		config = function()
			require("obsidian").setup({
				dir = "~/Sync/Notes/Current",
				completion = {
					nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
				},
				note_id_func = function(title)
					-- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
					local suffix = ""
					if title ~= nil then
						-- If title is given, transform it into valid file name.
						suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
					else
						-- If title is nil, just add 4 random uppercase letters to the suffix.
						for _ = 1, 4 do
							suffix = suffix .. string.char(math.random(65, 90))
						end
					end
					return tostring(os.time()) .. "-" .. suffix
				end,
			})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		config = function()
			-- require("copilot").setup()
			require("copilot").setup({
				panel = {
					enabled = true,
					auto_refresh = true,
					keymap = {
						jump_prev = "[[",
						jump_next = "]]",
						accept = "<CR>",
						refresh = "gr",
						open = "<M-CR>",
					},
				},
				suggestion = {
					enabled = true,
					auto_trigger = true,
					debounce = 75,
					keymap = {
						accept = "<Tab>",
						next = "<M-N>",
						prev = "<M-P>",
						dismiss = "<C-]>",
					},
				},
				filetypes = {
					yaml = false,
					markdown = false,
					help = false,
					gitcommit = false,
					gitrebase = false,
					hgcommit = false,
					svn = false,
					cvs = false,
					["."] = false,
				},
				copilot_node_command = "node", -- Node.js version must be > 16.x
				server_opts_overrides = {},
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"zbirenbaum/copilot.lua",
		},
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	"folke/which-key.nvim",
	"folke/neodev.nvim",
	{
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({
				window = {
					width = 80,
				},
			})
		end,
	},

	"kylechui/nvim-surround",
	"jose-elias-alvarez/null-ls.nvim",

	"m-demare/hlargs.nvim",
	"lewis6991/gitsigns.nvim",
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
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		-- opts = {},
	},
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
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		version = "nightly",
	},
	"mhartington/formatter.nvim",

	-- == LSP ===
	"neovim/nvim-lspconfig",
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
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
	"jose-elias-alvarez/typescript.nvim",
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
	-- "aktersnurra/no-clown-fiesta.nvim",
	{
		dir = "~/mine/no-clown-fiesta.nvim",
	},
	"nyoom-engineering/oxocarbon.nvim",
})
