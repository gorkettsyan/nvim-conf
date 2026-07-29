-- Centers the current buffer on wide screens by padding both sides with
-- empty scratch buffers, so code sits mid-screen instead of hugging the
-- left edge.
--
-- Guarded: this file is a no-op until `:PackerSync` installs the plugin.

local ok, nnp = pcall(require, 'no-neck-pain')
if not ok then return end

nnp.setup({
  -- Controls the size of the left gap, but indirectly and inversely:
  -- the plugin computes  gap = (columns - 1 - width) / 2,  halving the
  -- leftover even when only one side is enabled.
  --
  --   BIGGER width  ->  SMALLER left gap
  --
  -- On a 220-column screen: width=100 -> ~59 gap; width=160 -> ~29 gap.
  width = 100,

  autocmds = {
    -- Center automatically on startup rather than needing a manual toggle.
    enableOnVimEnter = true,
    enableOnTabEnter = true,
  },

  buffers = {
    -- Left gap only: pads the left like a file-tree panel would, and lets the
    -- code run out to the right edge. Set right.enabled = true to re-center.
    left = { enabled = true },
    right = { enabled = false },
  },
})

vim.keymap.set('n', '<leader>wp', '<cmd>NoNeckPain<cr>',
  { silent = true, desc = 'Toggle centered buffer (no-neck-pain)' })
