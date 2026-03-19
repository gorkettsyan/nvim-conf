-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = 'v0.2.0',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    -- lua/plugins/rose-pine.lua
    use {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            vim.cmd("colorscheme rose-pine")
        end
    }

    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'theprimeagen/harpoon' }
    use { 'mbbill/undotree' }
    use { 'tpope/vim-fugitive' }
    use { 'thesimonho/kanagawa-paper.nvim' }
    use { 'neovim/nvim-lspconfig'}
    use { 'stevearc/conform.nvim' }
    use { 'mfussenegger/nvim-lint' }
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'
    use {
      'preservim/nerdtree',
      requires = { 'Xuyuanp/nerdtree-git-plugin' },
      config = function()
        vim.g.NERDTreeGitStatusIndicatorMapCustom = {
          Modified  = '✹',
          Staged    = '✚',
          Untracked = '✭',
          Renamed   = '➜',
          Unmerged  = '═',
          Deleted   = '✖',
          Dirty     = '✗',
          Ignored   = '☒',
          Clean     = '✔︎',
          Unknown   = '?',
        }
      end
    }
    use 'savq/melange-nvim'
    use {
      'zbirenbaum/copilot.lua',
      config = function()
        require('copilot').setup({
          suggestion = {
            auto_trigger = true,
            keymap = {
              accept = '<Tab>',
            },
          },
        })
      end,
    }
    use {
       'windwp/nvim-autopairs',
    }
    use 'catppuccin/nvim'
    use 'xero/miasma.nvim'
    use 'projekt0n/github-nvim-theme'
    use {
      'christoomey/vim-tmux-navigator',
      lazy = false,
    }
    use 'nvim-lualine/lualine.nvim'
    use 'folke/tokyonight.nvim'
end)
