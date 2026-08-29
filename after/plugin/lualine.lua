require('lualine').setup {
    options = {
        icons_enabled = false,
        theme = 'auto',
    },
    sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {
            {
                -- Buffer-local override wins, global flag otherwise.
                function()
                    local b = vim.b.copilot_suggestion_auto_trigger
                    if b == nil then b = vim.g.copilot_auto_trigger end
                    return b and 'AI' or 'AI off'
                end,
                cond = function()
                    return vim.g.copilot_auto_trigger ~= nil
                end,
            },
            {
                'diagnostics',
                symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
            },
        },
    },
}
