-- GitHub Copilot: inline AI completion as ghost text.
--
-- Lives here rather than in packer.lua's `config = function()` block, because
-- those only run via plugin/packer_compiled.lua -- which is stale on this
-- machine (Apr 16, vs packer.lua's Aug 26) and has no copilot entry at all.
-- That's why Copilot never started: setup() was never called. Files in
-- after/plugin/ always run, which is the pattern the rest of this config uses.
--
-- FIRST RUN: `:Copilot auth` to sign in. Requires an active Copilot
-- subscription. `:Copilot status` reports whether it's working.

local ok, copilot = pcall(require, 'copilot')
if not ok then return end

copilot.setup({
  suggestion = {
    enabled = true,
    -- Ghost text appears as you type -- no keypress to summon it.
    auto_trigger = true,
    -- Suppress ghost text while the nvim-cmp menu is open, so the two aren't
    -- drawing over each other.
    hide_during_completion = true,
    debounce = 75,
    keymap = {
      -- NOT <Tab>: nvim-cmp owns that for cycling its menu and the two fight
      -- silently. <C-y> is free in insert mode (verified against the full
      -- insert-mode keymap) and is the conventional "accept" key.
      accept = '<C-y>',
      dismiss = '<C-]>',
      -- copilot.lua defaults these to <M-]> / <M-[>, but Ghostty has no
      -- `macos-option-as-alt` set, so Alt chords never reach nvim here.
      -- Left off rather than bound to something that silently does nothing.
      accept_word = false,
      accept_line = false,
      next = false,
      prev = false,
      -- Ghost text off/on for this buffer, without leaving insert mode.
      toggle_auto_trigger = '<C-g>',
    },
  },

  -- The panel (a split listing ~10 alternatives) stays off; inline ghost text
  -- is the part worth having, and a split would fight neo-tree and dap-ui.
  panel = { enabled = false },

  filetypes = {
    -- Don't ship these buffers to the API.
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ['.'] = false,
    ['*'] = true,
  },
})

-- Global on/off switch. copilot.lua only tracks auto-trigger per buffer
-- (vim.b.copilot_suggestion_auto_trigger) with no writable global, so
-- vim.g.copilot_auto_trigger is the source of truth: the toggle writes every
-- loaded buffer, and BufEnter below seeds buffers opened later.
vim.g.copilot_auto_trigger = true

local function set_auto_trigger(state)
  vim.g.copilot_auto_trigger = state
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.b[buf].copilot_suggestion_auto_trigger = state
    end
  end
  if not state then
    require('copilot.suggestion').dismiss()
  end
  vim.notify('Copilot suggestions ' .. (state and 'on' or 'off'))
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('copilot_auto_trigger', { clear = true }),
  callback = function(args)
    if vim.b[args.buf].copilot_suggestion_auto_trigger == nil then
      vim.b[args.buf].copilot_suggestion_auto_trigger = vim.g.copilot_auto_trigger
    end
  end,
})

vim.keymap.set('n', '<leader>cp', '<cmd>Copilot status<cr>',
  { silent = true, desc = 'Copilot: status' })
vim.keymap.set('n', '<leader>ct', function()
  set_auto_trigger(not vim.g.copilot_auto_trigger)
end, { silent = true, desc = 'Copilot: toggle suggestions everywhere' })
vim.keymap.set('n', '<leader>cb', function()
  require('copilot.suggestion').toggle_auto_trigger()
end, { silent = true, desc = 'Copilot: toggle suggestions in this buffer' })
