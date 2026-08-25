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
    use {
        "rose-pine/neovim",
        name = "rose-pine",
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
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v3.x',
      requires = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-tree/nvim-web-devicons', -- optional; see after/plugin/neo-tree.lua
      },
    }
    use 'savq/melange-nvim'
    use {
      'zbirenbaum/copilot.lua',
      config = function()
        require('copilot').setup({
          suggestion = {
            enabled = false,
            auto_trigger = false,
            keymap = {
              accept = '<Tab>',
            },
          },
          panel = { enabled = false },
        })
        -- Belt-and-suspenders: force-disable on startup in case anything re-enables it.
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            pcall(vim.cmd, "Copilot disable")
          end,
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
    use 'mg979/vim-visual-multi'
    -- Low-saturation themes, for comparison against kanagawa-paper-ink (16%).
    -- Both are built on the premise that default syntax highlighting is too
    -- colourful, so they should land at or below that.
    use 'vague2k/vague.nvim'
    use 'aktersnurra/no-clown-fiesta.nvim'

    -- Smoothness: animated scrolling, keymap discovery, and a modern UI
    -- for messages/cmdline/LSP progress.
    use 'karb94/neoscroll.nvim'
    use 'folke/which-key.nvim'
    use {
      'folke/noice.nvim',
      requires = {
        'MunifTanjim/nui.nvim',
        'rcarriga/nvim-notify',
      },
    }

    use {
      'kawre/leetcode.nvim',
      requires = {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
      },
    }
end)
