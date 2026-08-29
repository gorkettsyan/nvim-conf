vim.g.mapleader = " "

-- vim-visual-multi. Its <C-Down>/<C-Up> defaults never arrive: macOS binds
-- Ctrl+arrows to Mission Control. <leader>m is the multi-cursor prefix instead.
vim.g.VM_maps = {
  ['Find Under'] = '<leader>n',         -- next occurrence of word (VSCode Cmd-D)
  ['Find Subword Under'] = '<leader>n', -- same, from a visual selection
  ['Add Cursor Down'] = '<leader>mj',   -- repeatable while multi-cursor is active
  ['Add Cursor Up'] = '<leader>mk',
  ['Add Cursor At Pos'] = '<leader>mm',
  ['Select All'] = '<leader>ma',        -- every occurrence of word under cursor
  ['Visual Cursors'] = '<leader>mc',    -- selection -> one cursor per line
  ['Visual Add'] = '<leader>mv',
}

vim.keymap.set("n", "<leader>pv", "<cmd>Neotree focus<cr>",
  { silent = true, desc = "Focus file tree (was netrw :Ex)" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.api.nvim_set_keymap(
  "n",
  "<leader>tf",
  "<Plug>PlenaryTestFile",
  { noremap = false, silent = false, desc = "Run Plenary tests for current file" }
)

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down and center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up and center cursor" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center/expand" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result and center/expand" })
vim.keymap.set("n", "=ap", "ma=ap'a", { desc = "Format paragraph and keep cursor position" })
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })

vim.keymap.set("n", "<leader>lt", function()
  vim.cmd [[ PlenaryBustedFile % ]]
end, { desc = "Run PlenaryBustedFile for current file" })

-- I/A from a plain v or V selection edit every line, instead of only the first,
-- by switching the selection to blockwise first (no <C-v> needed). V picks
-- column 1, v keeps the columns you selected, and A on a linewise selection
-- appends at each line's own end. <C-v> itself is left untouched.
--
-- Caveat: like all blockwise inserts this shows one cursor and only fills the
-- other lines on <Esc>, and it skips empty lines. For those, <leader>mc turns
-- the selection into real vim-visual-multi cursors, then press I.
vim.keymap.set("x", "I", function()
  local mode = vim.fn.mode()
  if mode == "V" then return "<C-v>0I" end
  if mode == "v" then return "<C-v>I" end
  return "I"
end, { expr = true, desc = "Insert at start of every selected line" })

vim.keymap.set("x", "A", function()
  local mode = vim.fn.mode()
  if mode == "V" then return "<C-v>$A" end
  if mode == "v" then return "<C-v>A" end
  return "A"
end, { expr = true, desc = "Append at end of every selected line" })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over selection without yanking" })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = "Delete without yanking" })

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set("n", "Q", "<nop>", {desc = "Disable Ex mode" })
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux sessionizer (new window)" })
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>", { desc = "Tmux sessionizer (vsplit)" })
vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "Tmux sessionizer -s 0 (new window)" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Quickfix: next item" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Quickfix: prev item" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Location list: next item" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Location list: prev item" })

vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor (global)" }
)

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- The <leader>ee / ea / ef / el Go error-check snippets used to live here as
-- GLOBAL normal-mode mappings, so they fired in Python, Lua, TS -- any
-- filetype. They now live in after/plugin/go.lua, scoped to Go buffers.
--
-- Side benefit: outside Go, <leader>e is no longer a prefix of anything, so
-- the diagnostic float (after/plugin/lsp.lua) fires instantly instead of
-- waiting out the full 1000ms timeoutlen.

vim.keymap.set("n", "<leader>ca", function()
  require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular automaton: make it rain" })

-- Source the current file -- only meaningful for Lua/Vimscript.
--
-- Unguarded, `:so` on any other filetype hands the buffer to the Ex
-- interpreter: a .ts file produces
--   E492: Not an editor command: import { ... } from "..."
-- because nvim tries to run line 1 as a command.
vim.keymap.set("n", "<leader><leader>", function()
  local ft = vim.bo.filetype
  if ft ~= "lua" and ft ~= "vim" then
    vim.notify(
      ("Not sourcing a %s file -- :so only runs Lua/Vimscript")
        :format(ft ~= "" and ft or "unknown"),
      vim.log.levels.WARN
    )
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer has no file to source", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(vim.cmd.source, file)
  if ok then
    vim.notify("Sourced " .. vim.fn.fnamemodify(file, ":~:."), vim.log.levels.INFO)
  else
    vim.notify("Source failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end, { desc = "Source current file (Lua/Vim only)" })

vim.keymap.set('n', '<leader>tt', '<cmd>Neotree toggle<cr>',
  { silent = true, desc = 'Toggle file tree (neo-tree)' })
vim.keymap.set('n', '<leader>tr', '<cmd>Neotree reveal<cr>',
  { silent = true, desc = 'Reveal current file in tree and focus it' })
-- `gd` is defined in after/plugin/lsp.lua (LSP with a grep fallback)
-- maximize / fullscreen current window
vim.keymap.set("n", "<leader>wo", "<C-w>o")   -- o = only

-- window navigation
vim.keymap.set("n", "<leader>wh", "<C-w>h")
vim.keymap.set("n", "<leader>wj", "<C-w>j")
vim.keymap.set("n", "<leader>wk", "<C-w>k")
vim.keymap.set("n", "<leader>wl", "<C-w>l")
-- Horizontal split
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })

-- Vertical split
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })

-- Split with a specific file
vim.keymap.set("n", "<leader>se", "<cmd>split | e ", { desc = "Split and edit file" })

-- Close current window
vim.keymap.set("n", "<leader>wc", "<cmd>close<CR>", { desc = "Close split" })


-- Window management
vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Window: only (maximize)" })
vim.keymap.set("n", "<leader>wq", "<C-w>q", { desc = "Window: close" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Window: equalize" })
-- NOTE: <leader>d is "delete without yanking" (defined above). Diagnostics are
-- on <leader>e -- see after/plugin/lsp.lua.

