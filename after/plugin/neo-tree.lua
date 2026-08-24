-- Zed-style project panel: a persistent left sidebar that always reveals
-- whatever file you jump into (Telescope, harpoon, gd, :e -- anything).
--
-- Guarded: this file is a no-op until `:PackerSync` installs the plugin.

local ok, neotree = pcall(require, 'neo-tree')
if not ok then return end

-- NOTE ON FONT SIZE: terminal Neovim draws every window into one uniform
-- character grid, so the tree cannot use a smaller font than your code.
-- Instead we make it read as *lighter*: narrow width, tight indent, dimmed
-- text. Adjust `width` and the NeoTree* highlights at the bottom to taste.

-- Set to true if you have a Nerd Font installed and want file-type glyphs.
-- (Your lualine has icons_enabled = false, so this defaults to off.)
local NERD_FONT = false

neotree.setup({
  -- Don't keep nvim alive just for the sidebar.
  close_if_last_window = true,
  popup_border_style = 'rounded',
  enable_git_status = true,
  enable_diagnostics = true,

  -- Netrw is out: opening any directory (`nvim .`, `:Ex`, `:e some/dir`)
  -- hands off to neo-tree in the sidebar instead of netrw's listing.
  filesystem = {
    hijack_netrw_behavior = 'open_default',

    -- THE ZED BEHAVIOUR: follow the active buffer, expanding into its
    -- directory. leave_dirs_open keeps folders you've expanded expanded,
    -- rather than collapsing everything on each jump.
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },

    -- Reflect external changes (git checkout, file created by a build) live.
    use_libuv_file_watcher = true,

    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = true,
      never_show = { '.DS_Store', '.git' },
    },
  },

  default_component_configs = {
    -- Tight indent: less horizontal noise, so a narrow panel still reads.
    indent = {
      indent_size = 2,
      padding = 0,
      with_expanders = true,
      expander_collapsed = '▸',
      expander_expanded = '▾',
    },
    icon = {
      folder_closed = '▸',
      folder_open = '▾',
      folder_empty = '▹',
      -- Blank rather than a glyph box when there's no Nerd Font.
      default = NERD_FONT and '' or ' ',
    },
    modified = { symbol = '●' },
    git_status = {
      -- Plain-text markers, matching your lualine diagnostics style.
      symbols = {
        added     = '+',
        modified  = '~',
        deleted   = '-',
        renamed   = '>',
        untracked = '?',
        ignored   = ' ',
        unstaged  = '*',
        staged    = '+',
        conflict  = '!',
      },
    },
    name = {
      use_git_status_colors = true,
    },
  },

  window = {
    position = 'left',
    width = 46,
    mappings = {
      -- Vim-native feel: l/h to descend/ascend, matching your hjkl habits.
      ['l'] = 'open',
      ['h'] = 'close_node',
      ['<cr>'] = 'open',
      ['s'] = 'open_split',
      ['v'] = 'open_vsplit',
      ['a'] = { 'add', config = { show_path = 'relative' } },
      ['d'] = 'delete',
      ['r'] = 'rename',
      ['y'] = 'copy_to_clipboard',
      ['x'] = 'cut_to_clipboard',
      ['p'] = 'paste_from_clipboard',
      ['R'] = 'refresh',
      ['H'] = 'toggle_hidden',
      ['?'] = 'show_help',
    },
  },
})

-- Dim the sidebar so it recedes next to your code. This is the closest
-- terminal equivalent to Zed's smaller panel font.
local function dim_neotree()
  vim.api.nvim_set_hl(0, 'NeoTreeNormal',   { link = 'NormalNC' })
  vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { link = 'NormalNC' })
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { link = 'Directory' })
  vim.api.nvim_set_hl(0, 'NeoTreeFileName',      { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'NeoTreeIndentMarker',  { link = 'NonText' })
  -- Keep the *active* file readable so "where am I" stays obvious.
  vim.api.nvim_set_hl(0, 'NeoTreeFileNameOpened', { link = 'Normal', bold = true })
end
dim_neotree()
-- Re-apply after any :colorscheme change, since that clears custom highlights.
vim.api.nvim_create_autocmd('ColorScheme', { callback = dim_neotree })

-- Open the panel on startup and keep it there.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  nested = true,
  callback = function()
    -- Skip the cases where a sidebar is just in the way.
    if vim.o.diff then return end                      -- nvim -d
    local ft = vim.bo.filetype
    if ft == 'gitcommit' or ft == 'gitrebase' then return end
    -- `show` opens the panel without stealing the cursor from your buffer.
    pcall(vim.cmd, 'Neotree show')
  end,
})
