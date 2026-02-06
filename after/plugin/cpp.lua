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
require('lint').linters_by_ft = {
  cpp = { 'clangtidy' },
  c = { 'clangtidy' },
}

-- Run linters on save and text change
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  pattern = { "*.cpp", "*.hpp", "*.c", "*.h", "*.cc", "*.cxx" },
  callback = function()
    require("lint").try_lint()
  end,
})

-- Configure diagnostics display
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Diagnostic signs in the gutter
local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- LSP Keymaps on attach
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    
    -- Only apply these keymaps for C++ files with clangd
    if client and client.name == 'clangd' then
      local opts = { buffer = bufnr, noremap = true, silent = true }
      
      -- Navigation
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
      
      -- Actions
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', '<leader>f', function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, opts)
      
      -- Clangd specific: switch between header/source
      vim.keymap.set('n', '<leader>h', '<cmd>ClangdSwitchSourceHeader<CR>', opts)
      
      -- Diagnostics
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
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
