-- Function to detect the terminal emulator
local function get_terminal_command()
  -- Check if we're on macOS
  if vim.fn.has('mac') == 1 then
    return 'open -a Terminal.app'
  -- Check for common Linux terminal emulators
  elseif vim.fn.executable('gnome-terminal') == 1 then
    return 'gnome-terminal --'
  elseif vim.fn.executable('konsole') == 1 then
    return 'konsole -e'
  elseif vim.fn.executable('xterm') == 1 then
    return 'xterm -e'
  elseif vim.fn.executable('alacritty') == 1 then
    return 'alacritty -e'
  elseif vim.fn.executable('kitty') == 1 then
    return 'kitty'
  elseif vim.fn.executable('wezterm') == 1 then
    return 'wezterm start --'
  else
    return nil
  end
end

-- Function to copy selected code to clipboard and open Claude terminal
local function copy_to_clipboard_and_open_claude()
  -- Get the visual selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
  
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  
  -- Get file information
  local relative_filename = vim.fn.expand('%')
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  
  -- Handle partial line selections
  if #lines > 0 then
    lines[1] = string.sub(lines[1], start_pos[3])
    if #lines == 1 then
      lines[1] = string.sub(lines[1], 1, end_pos[3] - start_pos[3] + 1)
    else
      lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
    end
  end
  
  local selected_text = table.concat(lines, "\n")
  
  if selected_text == "" or selected_text == nil then
    print("Error: No text selected")
    return
  end
  
  -- Create context message with file info
  local context = string.format(
    "File: %s\nLines: %d-%d\n\n```\n%s\n```",
    relative_filename,
    start_line,
    end_line,
    selected_text
  )
  
  -- Copy to clipboard
  if vim.fn.has('mac') == 1 then
    vim.fn.system('pbcopy', context)
    print("Context copied to clipboard!")
  elseif vim.fn.executable('xclip') == 1 then
    vim.fn.system('xclip -selection clipboard', context)
    print("Context copied to clipboard!")
  elseif vim.fn.executable('xsel') == 1 then
    vim.fn.system('xsel --clipboard --input', context)
    print("Context copied to clipboard!")
  elseif vim.fn.executable('wl-copy') == 1 then
    -- Wayland
    vim.fn.system('wl-copy', context)
    print("Context copied to clipboard!")
  else
    print("Error: No clipboard utility found (pbcopy, xclip, xsel, or wl-copy)")
    return
  end
  
  -- Get current working directory
  local cwd = vim.fn.getcwd()
  
  -- Open Claude in terminal at the current directory
  local term_cmd = get_terminal_command()
  
  if not term_cmd then
    print("Error: Could not detect terminal emulator")
    return
  end
  
  if vim.fn.has('mac') == 1 then
    -- For macOS Terminal, change to directory and then run Claude
    local cmd = string.format([[osascript -e 'tell application "Terminal" to do script "cd %s && claude --verbose"']], vim.fn.shellescape(cwd))
    vim.fn.system(cmd)
  else
    -- For Linux terminals, use the working-directory option or cd
    if term_cmd:match('gnome%-terminal') then
      local cmd = string.format('gnome-terminal --working-directory=%s -- bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('konsole') then
      local cmd = string.format('konsole --workdir %s -e bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('alacritty') then
      local cmd = string.format('alacritty --working-directory %s -e bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('kitty') then
      local cmd = string.format('kitty --directory=%s bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('wezterm') then
      local cmd = string.format('wezterm start --cwd %s -- bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    else
      -- Fallback: use cd command
      local cmd = string.format('%s bash -c "cd %s && claude --verbose" &', term_cmd, vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    end
  end
  
  print("Opened Claude in " .. cwd .. " - paste your code with Cmd+V / Ctrl+V")
end

-- Simple function to just open Claude CLI in external terminal
local function open_claude_terminal()
  -- Get current working directory
  local cwd = vim.fn.getcwd()
  
  local term_cmd = get_terminal_command()
  
  if not term_cmd then
    print("Error: Could not detect terminal emulator")
    return
  end
  
  if vim.fn.has('mac') == 1 then
    local cmd = string.format([[osascript -e 'tell application "Terminal" to do script "cd %s && claude --verbose"']], vim.fn.shellescape(cwd))
    vim.fn.system(cmd)
  else
    if term_cmd:match('gnome%-terminal') then
      local cmd = string.format('gnome-terminal --working-directory=%s -- bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('konsole') then
      local cmd = string.format('konsole --workdir %s -e bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('alacritty') then
      local cmd = string.format('alacritty --working-directory %s -e bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('kitty') then
      local cmd = string.format('kitty --directory=%s bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    elseif term_cmd:match('wezterm') then
      local cmd = string.format('wezterm start --cwd %s -- bash -c "claude --verbose" &', vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    else
      local cmd = string.format('%s bash -c "cd %s && claude --verbose" &', term_cmd, vim.fn.shellescape(cwd))
      vim.fn.system(cmd)
    end
  end
  
  print("Opened Claude in " .. cwd)
end

-- Create the mappings
vim.keymap.set('v', '<leader>cp', copy_to_clipboard_and_open_claude, { 
  noremap = true, 
  silent = true,
  desc = "Copy selection to clipboard and open Claude terminal in project directory"
})

vim.keymap.set('n', '<leader>co', open_claude_terminal, {
  noremap = true,
  silent = true,
  desc = "Open Claude CLI in external terminal in project directory"
})
