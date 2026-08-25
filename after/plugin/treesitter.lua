-- nvim-treesitter, MAIN branch.
--
-- The old config here used the master-branch API -- `ensure_installed`,
-- `highlight = { enable = true }`, `auto_install`, `fold` passed to setup().
-- On main, setup() accepts exactly one key (`install_dir`) and silently drops
-- everything else, so treesitter highlighting was never actually enabled:
-- buffers fell back to regex `syntax`, which is the usual cause of stutter
-- while typing in larger files.
--
-- On main you do the two jobs explicitly:
--   1. install parsers via require('nvim-treesitter').install(...)
--   2. start the highlighter per buffer via vim.treesitter.start()

local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then return end

ts.setup({
  install_dir = vim.fn.stdpath('data') .. '/site',
})

local ensure = {
  'lua', 'vim', 'vimdoc', 'query',
  'python', 'javascript', 'typescript', 'tsx',
  'go', 'gomod', 'gosum',
  'c', 'cpp', 'zig',
  'json', 'yaml', 'toml',
  'markdown', 'markdown_inline', 'bash',
  'gitcommit', 'diff',
}

-- Only install what's actually missing; installing is async and noisy.
local installed = {}
for _, parser in ipairs(ts.get_installed()) do
  installed[parser] = true
end

local missing = {}
for _, parser in ipairs(ensure) do
  if not installed[parser] then
    table.insert(missing, parser)
  end
end

if #missing > 0 then
  ts.install(missing)
end

-- Start the treesitter highlighter for any filetype that has a parser.
-- pcall because a filetype can map to a language whose parser isn't present,
-- and a hard error here would break opening the file entirely.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('gket_treesitter_start', { clear = true }),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == '' then return end

    -- Skip plugin UI buffers -- neo-tree renders its own highlights.
    if ft:match('^neo%-tree') then return end

    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then return end

    pcall(vim.treesitter.start, args.buf, lang)
  end,
})
