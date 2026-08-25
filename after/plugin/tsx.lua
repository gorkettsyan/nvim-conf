-- TSX/TypeScript React setup: ts_ls + nvim-cmp + prettier + eslint

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure ts_ls (TypeScript language server)
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
      },
    },
  },
})

vim.lsp.enable('ts_ls')

-- Setup conform.nvim for prettier (reads .prettierrc / prettier.config.js from project)
require("conform").setup({
  formatters_by_ft = {
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

-- Setup nvim-lint for eslint (reads .eslintrc / eslint.config from project)
-- Merge, don't assign: other language files register their own linters too.
local lint = require('lint')
lint.linters_by_ft = vim.tbl_extend('force', lint.linters_by_ft or {}, {
  typescript = { 'eslint' },
  typescriptreact = { 'eslint' },
  javascript = { 'eslint' },
  javascriptreact = { 'eslint' },
})

-- Run the linter on save only.
--
-- Previously this also fired on BufEnter, which re-ran eslint every time you
-- so much as switched windows -- and when eslint isn't installed for the
-- project, each one printed "Error running eslint: ENOENT" and cost a process
-- spawn. Guarding on executable() keeps projects without eslint silent.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function()
    if vim.fn.executable("eslint") == 1 or vim.fn.executable("npx") == 1 then
      require("lint").try_lint()
    end
  end,
})

-- LSP keymaps are defined centrally in after/plugin/lsp.lua
