vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw (Ex file explorer)" })

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

vim.keymap.set(
  "n",
  "<leader>ee",
  "oif err != nil {<CR>}<Esc>Oreturn err<Esc>",
  { desc = "Insert Go error check with return err" }
)

vim.keymap.set(
  "n",
  "<leader>ea",
  "oassert.NoError(err, \"\")<Esc>F\";a",
  { desc = "Insert assert.NoError(err, \"\")" }
)

vim.keymap.set(
  "n",
  "<leader>ef",
  "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj",
  { desc = "Insert Go error check with log.Fatalf" }
)

vim.keymap.set(
  "n",
  "<leader>el",
  "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i",
  { desc = "Insert Go error check with logger.Error" }
)

vim.keymap.set("n", "<leader>ca", function()
  require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular automaton: make it rain" })

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end, { desc = "Source current file" })

vim.keymap.set('n', '<leader>tt', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'gd', vim.lsp.buf.type_definition, { noremap = true, silent = true })
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
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

