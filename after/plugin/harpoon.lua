local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

require("harpoon").setup({
    menu = {
        width = math.min(vim.api.nvim_win_get_width(0) - 4, 120),
    },
})

vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "Harpoon: add file" })
vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon: toggle menu" })

-- Move focus out of a sidebar/utility window before opening a file.
--
-- harpoon's ui.nav_file() calls nvim_set_current_buf() directly, which
-- replaces whatever the *current* window holds. Pressing <leader>1 while
-- focused in neo-tree therefore loads your file into the sidebar window and
-- destroys the tree pane. Confirmed: filetype goes neo-tree -> lua in place.
local function leave_sidebar()
    local ft = vim.bo.filetype
    if ft ~= "neo-tree" and not ft:match("^neo%-tree") then
        return
    end

    -- Prefer a window already showing a real file.
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local bft = vim.bo[buf].filetype
        if not bft:match("^neo%-tree") and vim.bo[buf].buftype == "" then
            vim.api.nvim_set_current_win(win)
            return
        end
    end

    -- Nothing suitable open: make a window rather than eating the sidebar.
    vim.cmd("wincmd l")
    if vim.bo.filetype:match("^neo%-tree") then
        vim.cmd("vsplit")
    end
end

local function nav(i)
    leave_sidebar()

    local ok, err = pcall(ui.nav_file, i)
    if ok then return end

    -- Only the known-recoverable failure gets the fallback, and only when the
    -- mark actually resolves to a name -- `"edit " .. nil` would throw.
    if type(err) == "string" and err:match("Cursor position outside buffer") then
        local name = require("harpoon.mark").get_marked_file_name(i)
        if name and name ~= "" then
            vim.cmd("edit " .. vim.fn.fnameescape(name))
        end
    end
end

-- Sticky harpoon mode: press <leader>1-9 to enter, then keep pressing 1-9.
-- Only Esc exits the mode.
local harpoon_active = false
local harpoon_bufs = {} -- track buffers where we set keymaps

local function set_buf_keymaps(bufnr)
    if harpoon_bufs[bufnr] then return end
    harpoon_bufs[bufnr] = true
    for i = 1, 9 do
        vim.keymap.set("n", tostring(i), function()
            nav(i)
        end, { buffer = bufnr, nowait = true })
    end
    vim.keymap.set("n", "<Esc>", function()
        exit_harpoon_mode()
    end, { buffer = bufnr, nowait = true })
end

function exit_harpoon_mode()
    if not harpoon_active then return end
    harpoon_active = false
    for bufnr, _ in pairs(harpoon_bufs) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            for i = 1, 9 do
                pcall(vim.keymap.del, "n", tostring(i), { buffer = bufnr })
            end
            pcall(vim.keymap.del, "n", "<Esc>", { buffer = bufnr })
        end
    end
    harpoon_bufs = {}
    pcall(vim.api.nvim_del_augroup_by_name, "HarpoonMode")
    vim.api.nvim_echo({ { "" } }, false, {})
end

local function enter_harpoon_mode()
    if harpoon_active then return end
    harpoon_active = true
    harpoon_bufs = {}
    vim.api.nvim_echo({ { " harpoon [1-9] (Esc to exit) ", "ModeMsg" } }, false, {})

    set_buf_keymaps(vim.api.nvim_get_current_buf())

    local grp = vim.api.nvim_create_augroup("HarpoonMode", { clear = true })
    -- Re-apply keymaps on every new buffer we land in
    vim.api.nvim_create_autocmd("BufEnter", {
        group = grp,
        callback = function()
            if harpoon_active then
                set_buf_keymaps(vim.api.nvim_get_current_buf())
            end
        end,
    })
    -- Exit on insert/cmdline so normal editing isn't disrupted
    vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
        group = grp,
        once = true,
        callback = function()
            vim.schedule(exit_harpoon_mode)
        end,
    })
end

for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, function()
        nav(i)
        enter_harpoon_mode()
    end, { desc = "Harpoon: file " .. i })
end
