local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    mappings = {
      -- In insert mode <leader> is a literal space, so a <leader>q binding here
      -- swallows every space typed in the prompt. Use <C-q> instead.
      i = {
        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
        ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
      },
      n = {
        ['<leader>q'] = actions.send_to_qflist + actions.open_qflist,
        ['<leader>Q'] = actions.send_selected_to_qflist + actions.open_qflist,
      },
    },
  },
})

vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope find git files' })
vim.keymap.set('n', '<leader>ps', function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = 'Telescope grep (one-shot prompt)' })

-- Incremental grep: refine the query as you type. The everyday workhorse.
vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = 'Telescope live grep' })

-- Grep whatever is under the cursor, no prompt.
vim.keymap.set('n', '<leader>pw', builtin.grep_string, { desc = 'Telescope grep word under cursor' })

-- Your working set: open buffers and recently edited files.
vim.keymap.set('n', '<leader>pb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>po', builtin.oldfiles, { desc = 'Telescope recent files' })

-- Reopen the last picker with its query and cursor position intact.
vim.keymap.set('n', '<leader>pr', builtin.resume, { desc = 'Telescope resume last picker' })

