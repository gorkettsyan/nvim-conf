-- Colourscheme + transparency.
--
-- Every theme here runs with a transparent background so Ghostty's blur shows
-- through. Neovim cannot blur anything itself -- it can only decline to paint
-- a background. The blur lives in ~/.config/ghostty/config, where
-- `background-blur` requires `background-opacity` < 1 to do anything.
--
--------------------------------------------------------------------------
-- Why no-clown-fiesta
--------------------------------------------------------------------------
--
-- Measured across dark themes: mean HSL saturation of the syntax groups
-- (how colourful), and the worst group's WCAG contrast (what limits reading,
-- almost always Comment).
--
--   THEME                      SAT   WORST
--   no-clown-fiesta             7%   3.80  <- this one, fixed below to 5.02
--   kanagawa-paper-ink         21%   3.33  (fixed below to 5.03)
--   vague                      28%   3.02
--   melange                    44%   4.80  (the only one passing untouched)
--   github_dark_high_contrast  74%   9.23
--
-- AA is 4.5, AAA is 7.0. Note the pattern: the calmer a theme is, the worse
-- its contrast, because dropping hue as a way to separate tokens forces it to
-- lean on lightness, and dim greys are where contrast dies. The overrides
-- below repair that in the two themes worth using.
--------------------------------------------------------------------------

-- no-clown-fiesta: the primary. Near-monochrome greys.
local ok_ncf, ncf = pcall(require, 'no-clown-fiesta')
if ok_ncf then
  ncf.setup({
    transparent = true,
    styles = {
      comments = { italic = true },
    },
  })
end

-- kanagawa-paper: kept configured as the fallback if 7% reads too flat.
local ok_kana, kanagawa = pcall(require, 'kanagawa-paper')
if ok_kana then
  kanagawa.setup({
    transparent = true,
    dim_inactive = false,
    gutter = false,
    diag_background = false,
    styles = { comment = { italic = true } },
    overrides = function()
      return {
        Comment = { fg = '#908f86', italic = true }, -- 3.33 -> 5.03
        LineNr  = { fg = '#7b7b9a' },                -- 2.23 -> 4.00
      }
    end,
  })
end

-- github: kept for when maximum readability beats calm (worst group 9.23).
local ok_gh, github = pcall(require, 'github-theme')
if ok_gh then
  github.setup({
    options = {
      transparent = true,
      hide_end_of_buffer = true,
      hide_nc_statusline = true,
      styles = { comments = 'italic' },
    },
  })
end

--------------------------------------------------------------------------
-- Per-theme contrast repairs
--------------------------------------------------------------------------
--
-- Applied after :colorscheme, since themes without an `overrides` hook (like
-- no-clown-fiesta) can only be corrected afterwards. Each colour is the
-- original raised in LIGHTNESS ONLY, holding hue and saturation, so the
-- palette still looks like itself -- these greys stay pure grey (R=G=B).

local REPAIRS = {
  ['no-clown-fiesta'] = {
    Comment = { fg = '#868686', italic = true }, -- 3.80 -> 5.02
    LineNr  = { fg = '#767676' },                -- 3.80 -> 4.02
  },
  ['vague'] = {
    Comment = { fg = '#85859e', italic = true }, -- 3.02 -> 5.13
    LineNr  = { fg = '#747491' },                -- 3.02 -> 4.08
  },
  ['github_dark'] = {
    Comment = { fg = '#a0a7af', italic = true }, -- 3.97 -> 5.02
    LineNr  = { fg = '#8e959e' },                -- 2.66 -> 4.03
  },
}

-- Groups that commonly keep an opaque background even under a theme's own
-- transparent mode. Clearing them is what removes the visible "panes".
local TRANSPARENT_GROUPS = {
  'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder', 'FloatTitle',
  'SignColumn', 'LineNr', 'CursorLineNr', 'FoldColumn', 'EndOfBuffer',
  'WinSeparator', 'VertSplit',
  'StatusLine', 'StatusLineNC', 'MsgArea', 'MsgSeparator',
  'TabLine', 'TabLineFill', 'TabLineSel',
  'Pmenu', 'PmenuSbar', 'PmenuThumb',
  'NeoTreeNormal', 'NeoTreeNormalNC', 'NeoTreeEndOfBuffer', 'NeoTreeWinSeparator',
  'NeoTreeFloatNormal', 'NeoTreeFloatBorder', 'NeoTreeTitleBar',
  'TelescopeNormal', 'TelescopeBorder', 'TelescopePromptNormal',
  'TelescopePromptBorder', 'TelescopeResultsNormal', 'TelescopeResultsBorder',
  'TelescopePreviewNormal', 'TelescopePreviewBorder',
  'WhichKeyFloat', 'WhichKeyBorder', 'NoiceCmdlinePopup', 'NoiceCmdlinePopupBorder',
}

local function apply_theme_tweaks()
  -- Contrast repairs first, so the transparency pass below can strip any
  -- background they might carry.
  local repairs = REPAIRS[vim.g.colors_name or '']
  if repairs then
    for group, spec in pairs(repairs) do
      pcall(vim.api.nvim_set_hl, 0, group, spec)
    end
  end

  for _, group in ipairs(TRANSPARENT_GROUPS) do
    -- Preserve fg/style, drop only the background.
    local existing = vim.api.nvim_get_hl(0, { name = group, link = false })
    existing.bg = nil
    existing.ctermbg = nil
    pcall(vim.api.nvim_set_hl, 0, group, existing)
  end
end

-- Kept as a global with the same name/behaviour as before, so
-- `:lua setColor('melange')` still works for trying alternatives in place.
function setColor(color)
  color = color or 'github_dark'
  vim.cmd.colorscheme(color)
  apply_theme_tweaks()
end

-- Re-apply after any colorscheme change, including ones made by hand later.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('gket_theme_tweaks', { clear = true }),
  callback = apply_theme_tweaks,
})

setColor()
