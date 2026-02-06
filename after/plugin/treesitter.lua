require'nvim-treesitter'.setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site',

  ensure_installed = { "help", "lua", "python", "javascript", "typescript", "vim", }, -- Install these parsers
  sync_install = false, -- Don't block startup for installs
  highlight = {
    enable = true, -- Enable syntax highlighting
    additional_vim_regex_highlighting = false,
  },
  -- Optional: Enable folding using Tree-sitter
  fold = {
    enable = true,
    -- foldexpr = 'v:lua.vim.treesitter.foldexpr()', -- Often set automatically
    -- foldmethod = 'expr', -- Often set automatically
  },

  auto_install = true
  -- Optional: For text objects, use nvim-treesitter-textobjects plugin
  -- textobjects = {
  --   enable = true,
  -- }
}
