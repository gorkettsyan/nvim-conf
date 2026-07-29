-- Zig setup: syntax highlighting + format on save only (no LSP/completion/copilot)

-- Format on save with zig fmt
require("conform").setup({
  formatters_by_ft = {
    zig = { "zigfmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = false,
  },
})

-- Disable cmp and copilot for zig files
local cmp = require('cmp')
cmp.setup.filetype({ 'zig', 'zon' }, {
  enabled = false,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'zig', 'zon' },
  callback = function()
    -- Disable Copilot suggestions
    vim.b.copilot_suggestion_auto_trigger = false
    vim.b.copilot_suggestion_hidden = true
  end,
})
