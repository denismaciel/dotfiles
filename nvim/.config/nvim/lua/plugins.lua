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
    use {
      'lewis6991/gitsigns.nvim',
      requires = {'nvim-lua/plenary.nvim'},
      config = require('gitsigns-config'),
    }

    use 'tpope/vim-commentary'
    use 'editorconfig/editorconfig-vim'
    use 'vimwiki/vimwiki'
    -- Plug 'kyazdani42/nvim-web-devicons'
    -- Plug 'kyazdani42/nvim-tree.lua'
    use 'mbbill/undotree'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'nvim-treesitter/nvim-treesitter-textobjects'
     use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("trouble").setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        }
      end
    }
    use 'ThePrimeagen/harpoon'
    use 'windwp/nvim-autopairs'
    use 'windwp/nvim-ts-autotag'
    use 'ggandor/lightspeed.nvim'
    use 'APZelos/blamer.nvim'
    use 'ludovicchabant/vim-gutentags'
    -- == LSP ===
    use 'neovim/nvim-lspconfig'
    use 'onsails/vimway-lsp-diag.nvim'
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
    use 'marko-cerovac/material.nvim'
    use 'Mofiqul/vscode.nvim'
    use 'rebelot/kanagawa.nvim'


    require('leap').setup {
      case_insensitive = true,
    }
end)

