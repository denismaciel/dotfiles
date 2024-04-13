local hi = function(name, val)
    -- Force links
    val.force = true

    -- Make sure that `cterm` attribute is not populated from `gui`
    val.cterm = val.cterm or {}

    -- Define global highlight
    vim.api.nvim_set_hl(0, name, val)
end
hi('CursorLine', {
    bg = 'Red',
    cterm = { underline = true },
})

print('hello')

vim.api.nvim_create_autocmd(
    'ColorScheme',
    { command = [[highlight CursorLine guibg=NONE cterm=underline]] }
)
