require('lualine').setup {
    options = {
        icons_enabled = false,
        theme = 'auto',
    },
    sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {
            {
                'diagnostics',
                symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
            },
        },
    },
}
