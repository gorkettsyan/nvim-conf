-- Complete C++ setup: clangd + nvim-cmp + clang-format + clang-tidy
-- Place this in your init.lua or a separate file like lua/lsp/cpp.lua

-- INSTALLATION (using Packer):
-- Completion plugins (if not already installed)
-- use 'hrsh7th/nvim-cmp'
-- use 'hrsh7th/cmp-nvim-lsp'
-- use 'hrsh7th/cmp-buffer'
-- use 'hrsh7th/cmp-path'
-- use 'L3MON4D3/LuaSnip'
-- use 'saadparwaiz1/cmp_luasnip'

-- Formatting and linting
-- use 'stevearc/conform.nvim'
-- use 'mfussenegger/nvim-lint'

-- Install C++ tools:
-- brew install llvm  (macOS)
-- sudo apt install clangd clang-format clang-tidy  (Linux)

-- Setup nvim-cmp (if not already configured)
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

-- Setup conform.nvim for clang-format
require("conform").setup({
  formatters_by_ft = {
    cpp = { "clang_format" },
    c = { "clang_format" },
  },
  formatters = {
    clang_format = {
      -- Looks for .clang-format in project root automatically
      prepend_args = function()
        return { "--style=file" }  -- Use .clang-format if it exists
      end,
    },
  },
  -- Format on save
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

-- Setup nvim-lint for clang-tidy
-- Merge, don't assign: other language files register their own linters too.
local lint = require('lint')
lint.linters_by_ft = vim.tbl_extend('force', lint.linters_by_ft or {}, {
  cpp = { 'clangtidy' },
  c = { 'clangtidy' },
})

-- Run linters on save only. BufEnter re-ran clang-tidy on every window
-- switch, which is expensive and errors loudly when clang-tidy isn't present.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.cpp", "*.hpp", "*.c", "*.h", "*.cc", "*.cxx" },
  callback = function()
    if vim.fn.executable("clang-tidy") == 1 then
      require("lint").try_lint()
    end
  end,
})

-- Diagnostic display and sign icons are configured in after/plugin/lsp.lua

-- Shared LSP keymaps live in after/plugin/lsp.lua; only the clangd-specific
-- header/source toggle is defined here.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'clangd' then
      vim.keymap.set('n', '<leader>h', '<cmd>ClangdSwitchSourceHeader<CR>',
        { buffer = args.buf, silent = true, desc = 'Switch header/source' })
    end
  end,
})

-- Configure clangd with cmp capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=detailed',
    '--function-arg-placeholders',
    '--fallback-style=llvm',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac',
    '.git',
  },
  capabilities = capabilities,
})

-- Enable clangd for C/C++ files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  callback = function()
    vim.lsp.enable('clangd')
    
    -- Set column ruler (optional, adjust to your style)
    vim.opt_local.colorcolumn = "80"
  end,
})
