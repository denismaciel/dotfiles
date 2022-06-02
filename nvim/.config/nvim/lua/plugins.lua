-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    -- Candidate packages
    use 'ggandor/leap.nvim'
    use 'pineapplegiant/spaceduck'

    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use 'christoomey/vim-tmux-navigator'
    use 'nvim-lua/plenary.nvim'
    use { 'nvim-telescope/telescope.nvim', requires = { {'nvim-lua/plenary.nvim'} }}
    use { "nvim-telescope/telescope-file-browser.nvim" }
    use 'tpope/vim-commentary'
    use 'editorconfig/editorconfig-vim'
    use 'vimwiki/vimwiki'
    use 'mbbill/undotree'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'nvim-treesitter/nvim-treesitter-textobjects'
    use 'windwp/nvim-autopairs'
    use 'windwp/nvim-ts-autotag'
    use 'APZelos/blamer.nvim'
    use 'ludovicchabant/vim-gutentags'
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {
          'kyazdani42/nvim-web-devicons',
        },
        tag = 'nightly'
    }
    -- == LSP ===
    use 'neovim/nvim-lspconfig'
    use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("trouble").setup({})
      end
    }
    -- === Completion ===
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/vim-vsnip-integ'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    -- === Colors ===
    use 'rktjmp/lush.nvim'
    use 'mcchrish/zenbones.nvim'
    use 'morhetz/gruvbox'
    use 'savq/melange'
    use 'rebelot/kanagawa.nvim'
    use 'projekt0n/github-nvim-theme'
    use 'kdheepak/monochrome.nvim'

    use "rafamadriz/neon"
    use 'alexanderjeurissen/lumiere.vim'
    use 'rmehri01/onenord.nvim'

    require('leap').set_default_keymaps()
    require('nvim-tree').setup()
end)

