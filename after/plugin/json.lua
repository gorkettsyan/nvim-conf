-- JSON: format on save.
--
-- `stop_after_first` runs the first formatter that is actually installed, so
-- this prefers prettier when present and falls back to jq (ships with macOS).
--
-- jsonc deliberately does NOT use jq: jq cannot parse comments and would
-- either fail or strip them.

require("conform").setup({
  formatters_by_ft = {
    json = { "prettier", "jq", stop_after_first = true },
    jsonc = { "prettier", stop_after_first = true },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = true,
  },
})

-- 2-space indent is the JSON convention, and conform's jq formatter derives
-- its --indent flag from shiftwidth (which is 4 globally in lua/gket/set.lua).
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'json', 'jsonc' },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})
