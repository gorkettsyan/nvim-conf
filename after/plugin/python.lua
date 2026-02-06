local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})
-- Function to find Python executable in virtual environment
local function get_python_path()
  -- Check for common venv locations
  local venv_paths = {
    '.venv/bin/python',
    'venv/bin/python',
    '.venv/Scripts/python.exe',  -- Windows
    'venv/Scripts/python.exe',   -- Windows
  }
  
  for _, path in ipairs(venv_paths) do
    local full_path = vim.fn.getcwd() .. '/' .. path
    if vim.fn.executable(full_path) == 1 then
      return full_path
    end
  end
  
  -- Fall back to system python
  return vim.fn.exepath('python3')
end

vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
  capabilities = capabilities,
  settings = {
    pyright = {
      autoImportCompletion = true,
    },
    python = {
      pythonPath = get_python_path(),  -- Auto-detect venv
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'basic',
        extraPaths = {  -- Add your source directories if needed
          vim.fn.getcwd() .. '/src',
        },
      }
    }
  }
})


vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }


-- Enable Pyright for Python files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.lsp.enable('pyright')
  end,
})

-- Configure diagnostics display
vim.diagnostic.config({
  virtual_text = true,  -- Show errors inline
  signs = true,         -- Show signs in gutter
  underline = true,     -- Underline errors
  update_in_insert = false,
  severity_sort = true,
})

-- Setup conform.nvim for formatting
require("conform").setup({
  formatters = {
    black = {
      prepend_args = { "--config", "pyproject.toml" },
    },
  },
  formatters_by_ft = {
    python = { "black" },
  },
  -- Format on save
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

-- Setup nvim-lint for linting
require('lint').linters_by_ft = {
  python = { 'flake8', 'mypy' },
}

