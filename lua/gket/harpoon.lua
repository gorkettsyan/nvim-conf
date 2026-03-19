local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

require("harpoon").setup({
    menu = {
        width = math.min(vim.api.nvim_win_get_width(0) - 4, 120),
    },
})

vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "Harpoon: add file" })
vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon: toggle menu" })

local function nav(i)
    local ok, err = pcall(ui.nav_file, i)
    if not ok and err:match("Cursor position outside buffer") then
        vim.cmd("edit " .. require("harpoon.mark").get_marked_file_name(i))
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
