-- Debugging via DAP -- the same Debug Adapter Protocol VS Code uses, so the
-- model carries over: breakpoints, step over/into/out, a variables pane, a REPL.
--
-- Guarded: this file is a no-op until `:PackerSync` installs the plugins.
--
--------------------------------------------------------------------------
-- EXTERNAL DEBUGGERS -- the nvim plugins are only half of it
--------------------------------------------------------------------------
--   Python : pip3 install debugpy
--   Go     : go install github.com/go-delve/delve/cmd/dlv@latest
--            (ensure $(go env GOPATH)/bin is on PATH)
--   C/C++/Zig : brew install llvm        -- provides lldb-dap
--   TS/JS  : see the js-debug section near the bottom; it needs a manual
--            download and is the fiddliest of the four.
--
-- :checkhealth dap  reports what it can actually find.
--------------------------------------------------------------------------

local ok_dap, dap = pcall(require, 'dap')
if not ok_dap then return end

--------------------------------------------------------------------------
-- UI: panels on session start, inline variable values
--------------------------------------------------------------------------

local ok_ui, dapui = pcall(require, 'dapui')
if ok_ui then
  dapui.setup({
    icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
    controls = { enabled = false }, -- the F-keys below are the interface
    layouts = {
      {
        elements = {
          { id = 'scopes',      size = 0.40 },
          { id = 'breakpoints', size = 0.20 },
          { id = 'stacks',      size = 0.25 },
          { id = 'watches',     size = 0.15 },
        },
        size = 44,
        position = 'right', -- neo-tree owns the left side
      },
      {
        elements = { { id = 'repl', size = 0.5 }, { id = 'console', size = 0.5 } },
        size = 10,
        position = 'bottom',
      },
    },
  })

  -- Open on session start, close when it ends.
  dap.listeners.before.attach.dapui_config = function() dapui.open() end
  dap.listeners.before.launch.dapui_config = function() dapui.open() end
  dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
  dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
end

local ok_vt, vt = pcall(require, 'nvim-dap-virtual-text')
if ok_vt then
  vt.setup({
    commented = true, -- render values as comments, so they read as annotation
    virt_text_pos = 'eol',
  })
end

--------------------------------------------------------------------------
-- Breakpoint signs -- matching the diagnostic glyphs in lsp.lua
--------------------------------------------------------------------------

vim.fn.sign_define('DapBreakpoint',
  { text = '●', texthl = 'DiagnosticError', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition',
  { text = '◆', texthl = 'DiagnosticWarn', numhl = '' })
vim.fn.sign_define('DapLogPoint',
  { text = '◈', texthl = 'DiagnosticInfo', numhl = '' })
vim.fn.sign_define('DapStopped',
  { text = '▶', texthl = 'DiagnosticOk', linehl = 'Visual', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected',
  { text = '○', texthl = 'Comment', numhl = '' })

--------------------------------------------------------------------------
-- Python -- debugpy
--------------------------------------------------------------------------

local ok_py, dap_python = pcall(require, 'dap-python')
if ok_py then
  -- Prefer a debugpy inside the active virtualenv, else fall back to the
  -- interpreter on PATH. Mirrors what python.lua does for the LSP.
  local venv = os.getenv('VIRTUAL_ENV')
  local python = venv and (venv .. '/bin/python') or vim.fn.exepath('python3')
  if python ~= '' then
    dap_python.setup(python)
    dap_python.test_runner = 'pytest'
  end
end

--------------------------------------------------------------------------
-- Go -- delve
--------------------------------------------------------------------------

local ok_go, dap_go = pcall(require, 'dap-go')
if ok_go then
  -- Resolve delve explicitly rather than trusting PATH. `go install` puts it
  -- in $(go env GOPATH)/bin, which is not on this machine's PATH -- and a
  -- GUI-launched nvim wouldn't inherit the shell's PATH regardless.
  local delve = vim.fn.exepath('dlv')
  if delve == '' then
    local gopath = vim.trim(vim.fn.system('go env GOPATH'))
    local candidate = gopath .. '/bin/dlv'
    if vim.v.shell_error == 0 and vim.fn.executable(candidate) == 1 then
      delve = candidate
    end
  end

  if delve ~= '' then
    dap_go.setup({ delve = { path = delve } })
  else
    dap_go.setup()
  end
end

--------------------------------------------------------------------------
-- C / C++ / Zig -- lldb-dap (brew install llvm)
--------------------------------------------------------------------------

local lldb = vim.fn.exepath('lldb-dap')
if lldb == '' then
  -- Homebrew keeps llvm keg-only, so it's usually not on PATH.
  local brewed = '/opt/homebrew/opt/llvm/bin/lldb-dap'
  if vim.fn.executable(brewed) == 1 then lldb = brewed end
end

if lldb ~= '' then
  dap.adapters.lldb = { type = 'executable', command = lldb, name = 'lldb' }

  local function pick_binary()
    -- Asked once per session start; debug builds only (needs -g).
    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
  end

  local lldb_config = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      program = pick_binary,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
  }

  dap.configurations.c = lldb_config
  dap.configurations.cpp = lldb_config
  dap.configurations.zig = lldb_config
end

--------------------------------------------------------------------------
-- TypeScript / JavaScript -- vscode-js-debug
--------------------------------------------------------------------------
--
-- The fiddliest one, as flagged. It needs Microsoft's js-debug built or
-- downloaded manually -- there is no plugin that ships it:
--
--   mkdir -p ~/.local/share/nvim/js-debug && cd ~/.local/share/nvim/js-debug
--   curl -sL https://github.com/microsoft/vscode-js-debug/releases/latest/download/js-debug-dap-v1.99.0.tar.gz | tar xz --strip-components=1
--
-- (check the releases page for the current version number)
--
-- Until that exists this block is skipped, so nothing breaks meanwhile.

local js_debug = vim.fn.expand('~/.local/share/nvim/js-debug/src/dapDebugServer.js')
if vim.fn.filereadable(js_debug) == 1 then
  dap.adapters['pwa-node'] = {
    type = 'server',
    host = 'localhost',
    port = '${port}',
    executable = {
      command = 'node',
      args = { js_debug, '${port}' },
    },
  }

  for _, ft in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }) do
    dap.configurations[ft] = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch current file',
        program = '${file}',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        -- ts-node so .ts runs without a separate build step.
        runtimeArgs = { '--loader=ts-node/esm' },
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to process',
        processId = function()
          return require('dap.utils').pick_process()
        end,
        cwd = '${workspaceFolder}',
      },
    }
  end
end

--------------------------------------------------------------------------
-- Keymaps -- F-keys matching VS Code, plus <leader>d for the rest
--------------------------------------------------------------------------

local function map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { silent = true, desc = 'Debug: ' .. desc })
end

-- VS Code parity
map('<F5>',   dap.continue,          'Start / continue')
map('<F10>',  dap.step_over,         'Step over')
map('<F11>',  dap.step_into,         'Step into')
map('<F12>',  dap.step_out,          'Step out')
map('<F9>',   dap.toggle_breakpoint, 'Toggle breakpoint')

-- <leader>d namespace. NOTE: <leader>d alone is "delete without yanking"
-- (remap.lua), so these add a 1000ms timeoutlen pause to that key -- the same
-- prefix problem <leader>e had. Rebind here if that bites.
map('<leader>db', dap.toggle_breakpoint, 'Toggle breakpoint')
map('<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, 'Conditional breakpoint')
map('<leader>dl', function()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log message: '))
end, 'Log point')
map('<leader>dc', dap.continue,      'Continue')
map('<leader>dt', dap.terminate,     'Terminate session')
map('<leader>dR', dap.restart,       'Restart session')
map('<leader>dr', dap.repl.toggle,   'Toggle REPL')
map('<leader>dh', function() require('dap.ui.widgets').hover() end, 'Hover value')

if ok_ui then
  map('<leader>du', dapui.toggle, 'Toggle debug UI')
  map('<leader>de', function() dapui.eval(nil, { enter = true }) end, 'Evaluate expression')
end

-- Language-specific test helpers
map('<leader>dP', function()
  local ok, dp = pcall(require, 'dap-python')
  if ok then dp.test_method() end
end, 'Python: debug nearest test')

map('<leader>dG', function()
  local ok, dg = pcall(require, 'dap-go')
  if ok then dg.debug_test() end
end, 'Go: debug nearest test')
