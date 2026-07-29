-- Go setup: gopls + goimports formatting
--
-- Install Go tools:
--   brew install go
--   go install golang.org/x/tools/gopls@latest
--   go install golang.org/x/tools/cmd/goimports@latest
-- Ensure $(go env GOPATH)/bin is on PATH.

require("conform").setup({
  formatters_by_ft = {
    go = { "goimports", "gofmt" },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = true,
  },
})

-- LSP keymaps are defined centrally in after/plugin/lsp.lua

-- Organize imports on save via gopls code action
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.go' },
  callback = function()
    local params = vim.lsp.util.make_range_params(0, 'utf-8')
    params.context = { only = { 'source.organizeImports' } }
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 1000)
    for _, res in pairs(result or {}) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
        end
      end
    end
  end,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  capabilities = capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = false,
      completeUnimported = true,
      usePlaceholders = true,
    },
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'gomod', 'gowork', 'gotmpl' },
  callback = function()
    vim.lsp.enable('gopls')
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
