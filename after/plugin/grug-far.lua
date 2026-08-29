local ok, grug = pcall(require, 'grug-far')
if not ok then
  return
end

grug.setup({})

vim.keymap.set('n', '<leader>rr', function()
  grug.open()
end, { desc = 'Grug-far: search & replace' })

vim.keymap.set('n', '<leader>rw', function()
  grug.open({ prefills = { search = vim.fn.expand('<cword>') } })
end, { desc = 'Grug-far: replace word under cursor' })

vim.keymap.set('n', '<leader>rF', function()
  grug.open({ prefills = { paths = vim.fn.expand('%') } })
end, { desc = 'Grug-far: replace in current file' })
