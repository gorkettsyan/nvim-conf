-- Central LSP setup: shared keymaps for every server + navigation helpers.
--
-- Per-language files (cpp.lua, go.lua, python.lua, tsx.lua) only declare their
-- own server via vim.lsp.config/enable. All keymaps live here so navigation
-- behaves identically in every language.

local capabilities = require('cmp_nvim_lsp').default_capabilities()

--------------------------------------------------------------------------
-- Servers that had no config of their own
--------------------------------------------------------------------------

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable('lua_ls')

--------------------------------------------------------------------------
-- Diagnostics (global -- applies to every language)
--------------------------------------------------------------------------

-- Sign icons belong here since Neovim 0.10. Defining DiagnosticSign* via
-- vim.fn.sign_define is deprecated.
vim.diagnostic.config({
  -- Off deliberately: the cursor line is rendered by virtual_lines below, and
  -- virtual_text has no "hide on current line" option -- only `current_line =
  -- true`, which is the opposite. Leaving both on double-prints every message
  -- on the line you're sitting on. Other lines still show a sign + underline.
  virtual_text = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN]  = '▲',
      [vim.diagnostic.severity.HINT]  = '⚑',
      [vim.diagnostic.severity.INFO]  = '»',
    },
  },
})

--------------------------------------------------------------------------
-- Auto-show the diagnostic under the cursor
--------------------------------------------------------------------------
--
-- Neovim 0.11's `virtual_lines` renders the full, untruncated message inline
-- below the cursor line. `current_line = true` limits it to the line you're on.
--
-- It has no debounce of its own, though: enabled statically it re-renders on
-- every cursor step, so scrolling through a file with errors makes the text
-- below the cursor jump constantly. So we toggle it on a timer instead, and
-- only bother when the line actually carries a diagnostic -- which means no
-- work at all for the vast majority of cursor movements.
--
-- Deliberately not using `updatetime`/CursorHold: yours is 50ms (see
-- lua/gket/set.lua) and other things want it that low.

local VL_DELAY_MS = 300

local vl_on = false
local vl_timer = nil

local function vl_set(on)
  if vl_on == on then return end
  vl_on = on
  vim.diagnostic.config({ virtual_lines = on and { current_line = true } or false })
end

local function vl_stop_timer()
  if vl_timer then
    vl_timer:stop()
    vl_timer:close()
    vl_timer = nil
  end
end

local function cursor_line_has_diagnostic()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  return #vim.diagnostic.get(0, { lnum = lnum }) > 0
end

local function vl_schedule()
  vl_stop_timer()
  vl_set(false) -- collapse immediately so the text stops shifting while moving
  if not cursor_line_has_diagnostic() then return end

  vl_timer = vim.uv.new_timer()
  vl_timer:start(VL_DELAY_MS, 0, vim.schedule_wrap(function()
    vl_stop_timer()
    -- Re-check: the cursor may have moved on, or insert mode started.
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= 'i' and cursor_line_has_diagnostic() then
      vl_set(true)
    end
  end))
end

local vl_group = vim.api.nvim_create_augroup('gket_diag_virtual_lines', { clear = true })

vim.api.nvim_create_autocmd({ 'CursorMoved', 'DiagnosticChanged' }, {
  group = vl_group,
  callback = vl_schedule,
})

-- Never expand while typing, or in a buffer you've left.
vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufLeave', 'WinLeave' }, {
  group = vl_group,
  callback = function()
    vl_stop_timer()
    vl_set(false)
  end,
})

--------------------------------------------------------------------------
-- Navigation helpers
--------------------------------------------------------------------------

local function definition_clients(bufnr)
  local found = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c:supports_method('textDocument/definition') then
      table.insert(found, c.name)
    end
  end
  return found
end

-- `gd` that never fails silently: uses LSP when a server can answer, and
-- otherwise falls back to a project-wide grep for the symbol under the cursor
-- while telling you *why* it fell back.
local function goto_definition()
  local bufnr = vim.api.nvim_get_current_buf()

  if #definition_clients(bufnr) > 0 then
    vim.lsp.buf.definition({ reuse_win = true })
    return
  end

  local word = vim.fn.expand('<cword>')
  local ft = vim.bo[bufnr].filetype
  vim.notify(
    ('No LSP definition provider for filetype %q - grepping for %q instead')
      :format(ft ~= '' and ft or 'none', word),
    vim.log.levels.WARN
  )

  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok and word ~= '' then
    builtin.grep_string({ search = word })
  end
end

-- Which servers are attached to this buffer, and can they navigate?
local function lsp_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify(
      ('No LSP client attached (filetype=%q). `gd` will fall back to grep.')
        :format(vim.bo[bufnr].filetype),
      vim.log.levels.WARN
    )
    return
  end

  local lines = {}
  for _, c in ipairs(clients) do
    table.insert(lines, ('%s  definition=%s  root=%s'):format(
      c.name,
      c:supports_method('textDocument/definition') and 'yes' or 'no',
      c.root_dir or 'n/a'
    ))
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('LspStatus', lsp_status, {
  desc = 'Show LSP clients attached to the current buffer',
})

--------------------------------------------------------------------------
-- Keymaps, applied once for every server that attaches
--------------------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('gket_lsp_attach', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    local builtin = require('telescope.builtin')

    -- Jump straight there
    map('gd', goto_definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('gi', vim.lsp.buf.implementation, 'Go to implementation')
    map('gt', vim.lsp.buf.type_definition, 'Go to type definition')

    -- Pick from a list, with a preview, when there is more than one result
    map('gr', builtin.lsp_references, 'References (Telescope)')
    map('<leader>gd', builtin.lsp_definitions, 'Definitions (Telescope)')
    map('<leader>gi', builtin.lsp_implementations, 'Implementations (Telescope)')

    -- Fuzzy-jump by symbol name; usually faster than chasing `gd` chains
    map('<leader>ds', builtin.lsp_document_symbols, 'Document symbols')
    map('<leader>ws', builtin.lsp_dynamic_workspace_symbols, 'Workspace symbols')

    map('K', vim.lsp.buf.hover, 'Hover docs')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>f', function()
      require('conform').format({ async = true, lsp_fallback = true })
    end, 'Format buffer')

    map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic')
    map('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Prev diagnostic')
    map(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')
  end,
})

-- Global fallback so `gd` still does something useful in buffers where no
-- server ever attaches (zig, markdown, config files, ...).
vim.keymap.set('n', 'gd', goto_definition, {
  silent = true,
  desc = 'Go to definition (LSP, or grep fallback)',
})
