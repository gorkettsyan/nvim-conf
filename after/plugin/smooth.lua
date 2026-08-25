-- Motion + UI smoothness.
--
-- Guarded: each block is a no-op until `:PackerSync` installs the plugin.
--
-- SCOPE NOTE: terminal Neovim scrolls in whole character cells, so "smooth"
-- here means animated line-by-line, not Zed's pixel-level glide. True
-- sub-line scrolling requires a GUI client (Neovide runs this same config).

--------------------------------------------------------------------------
-- neoscroll: animate <C-d>/<C-u>/<C-f>/<C-b>/zz instead of teleporting
--------------------------------------------------------------------------

local ok_scroll, neoscroll = pcall(require, 'neoscroll')
if ok_scroll then
  neoscroll.setup({
    -- Your remap.lua maps <C-d>/<C-u> to "<C-d>zz" (scroll + centre). Letting
    -- neoscroll own those keys itself would fight that, so they're excluded
    -- here and wired by hand below to animate *and* keep the centring.
    mappings = { '<C-f>', '<C-b>', 'zt', 'zz', 'zb' },
    hide_cursor = true,
    stop_eof = true,
    respect_scrolloff = true,
    cursor_scrolls_alone = true,
    duration_multiplier = 0.7, -- lower = snappier; 1.0 is the default
    easing = 'quadratic',
  })

  -- Preserve the "scroll then centre" behaviour from remap.lua, animated.
  vim.keymap.set({ 'n', 'v', 'x' }, '<C-d>', function()
    neoscroll.ctrl_d({ duration = 150, move_cursor = true })
  end, { silent = true, desc = 'Page down and center (animated)' })

  vim.keymap.set({ 'n', 'v', 'x' }, '<C-u>', function()
    neoscroll.ctrl_u({ duration = 150, move_cursor = true })
  end, { silent = true, desc = 'Page up and center (animated)' })
end

--------------------------------------------------------------------------
-- which-key: show what follows <leader> instead of guessing
--------------------------------------------------------------------------

local ok_wk, which_key = pcall(require, 'which-key')
if ok_wk then
  which_key.setup({
    preset = 'helix',
    -- 400ms: long enough that fluent sequences never trigger the popup,
    -- short enough that hesitating gets you the menu.
    delay = 400,
    icons = {
      -- Matches lualine's icons_enabled = false / no Nerd Font assumption.
      mappings = false,
    },
    win = { border = 'rounded' },
  })

  -- Names for the prefixes you already use, so the popup reads as a menu
  -- rather than a list of raw keys.
  which_key.add({
    { '<leader>p', group = 'project / pickers' },
    { '<leader>w', group = 'window' },
    { '<leader>s', group = 'split / substitute' },
    { '<leader>g', group = 'goto (telescope)' },
    { '<leader>t', group = 'tree / test' },
    { '<leader>e', group = 'error snippets + diagnostic' },
    { '<leader>d', group = 'delete (no yank)' },
    { ']', group = 'next' },
    { '[', group = 'prev' },
  })
end

--------------------------------------------------------------------------
-- noice: cmdline, messages and LSP progress in real floating windows
--------------------------------------------------------------------------

-- DISABLED. Set to true to re-enable.
--
-- noice creates persistent windows for its cmdline/message views -- observed
-- as two extra `ft=noice` windows present from startup, which is what made
-- `:q` appear to "split into 3 windows": closing the file window left
-- neo-tree plus those two behind.
--
-- neoscroll and which-key above are unaffected and stay on.
local NOICE_ENABLED = false

local ok_noice, noice = pcall(require, 'noice')
if NOICE_ENABLED and ok_noice then
  noice.setup({
    cmdline = {
      view = 'cmdline_popup', -- centred float instead of the bottom line
    },
    lsp = {
      -- Route LSP markdown through noice so hover/signature match everything
      -- else. `override` is what stops cmp and hover rendering differently.
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
      progress = { enabled = true }, -- LSP progress as a quiet corner spinner
      signature = { enabled = true },
    },
    presets = {
      bottom_search = true, -- classic bottom `/` rather than a float
      -- long_message_to_split deliberately OFF: it opens a real split window
      -- for long messages, which is a surprising layout change mid-edit and
      -- muddies diagnosing stray windows. Long messages stay in a float.
      long_message_to_split = false,
      lsp_doc_border = true,
    },
    routes = {
      -- Kill the "written" / search-wrap noise that forces redraws.
      { filter = { event = 'msg_show', kind = '', find = 'written' }, opts = { skip = true } },
      { filter = { event = 'msg_show', find = 'search hit BOTTOM' }, opts = { skip = true } },
      { filter = { event = 'msg_show', find = 'search hit TOP' }, opts = { skip = true } },
    },
  })

  local ok_notify, notify = pcall(require, 'notify')
  if ok_notify then
    notify.setup({
      background_colour = '#000000', -- required when the theme is transparent
      render = 'compact',
      stages = 'fade',
      timeout = 2500,
    })
    vim.notify = notify
  end
end
