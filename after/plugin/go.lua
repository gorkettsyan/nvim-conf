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

--------------------------------------------------------------------------
-- Go error-handling snippets
--------------------------------------------------------------------------
--
-- Moved here from lua/gket/remap.lua, where they were registered globally and
-- so inserted Go boilerplate into Python, Lua and TypeScript buffers too.
-- Buffer-local now, applied only to Go files.

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('gket_go_snippets', { clear = true }),
  pattern = { 'go', 'gomod' },
  callback = function(args)
    local function snip(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc })
    end

    snip('<leader>ee',
      'oif err != nil {<CR>}<Esc>Oreturn err<Esc>',
      'Go: if err != nil { return err }')

    snip('<leader>ea',
      'oassert.NoError(err, "")<Esc>F";a',
      'Go: assert.NoError(err, "")')

    snip('<leader>ef',
      'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj',
      'Go: if err != nil { log.Fatalf(...) }')

    snip('<leader>el',
      'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i',
      'Go: if err != nil { logger.Error(...) }')
  end,
})
