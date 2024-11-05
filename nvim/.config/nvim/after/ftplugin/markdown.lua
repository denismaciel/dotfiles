local me = require('me')
local dennich = require('dennich')

local function smart_paste(register)
    register = register or '+'
    local clipboard_content = vim.fn.getreg(register)
    print(clipboard_content)

    if dennich.is_url(clipboard_content) then
        local formatted_text = '[](' .. clipboard_content .. ')'
        vim.api.nvim_put({ formatted_text }, '', false, true)
        -- Move cursor to the closing bracket using F]
        local keys = vim.api.nvim_replace_termcodes('F]', true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
    else
        local keys = vim.api.nvim_replace_termcodes('p', true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
    end
end

local augroup =
    vim.api.nvim_create_augroup('CustomizeMarkdown', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        vim.api.nvim_buf_set_option(0, 'expandtab', true)
        vim.api.nvim_buf_set_option(0, 'shiftwidth', 2)
        vim.api.nvim_buf_set_option(0, 'tabstop', 2)

        vim.keymap.set('n', 'p', function()
            smart_paste('+')
        end, { buffer = true, desc = 'Smart paste for URLs in markdown' })

        -- Visual mode paste
        vim.keymap.set('v', 'p', function()
            smart_paste('+')
        end, { buffer = true, desc = 'Smart paste for URLs in markdown' })

        me.highlight_markdown_titles()
    end,
    group = augroup,
    pattern = { '*.md', '*.txt' },
})

vim.api.nvim_create_autocmd('BufRead', {
    callback = function()
        vim.api.nvim_win_set_option(0, 'wrap', true)
        vim.api.nvim_buf_set_option(0, 'conceallevel', 0)
    end,
    group = augroup,
    pattern = { '*.md', '*.txt' },
})

vim.keymap.set('n', '<C-N>', function()
    require('me').cycle_notes('up')
end)

vim.keymap.set('n', '<C-P>', function()
    require('me').cycle_notes('down')
end)

-- Toggle checkboxes
-- Copied from:
-- https://github.com/caarlos0/dotfiles/blob/c2b002dda2329d82d1e8ffd454c8e7957ae6cc75/modules/neovim/config/after/ftplugin/markdown.lua
local CR = vim.api.nvim_replace_termcodes('<cr>', true, true, true)
local function toggle_checkbox()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local lineno = cursor[1]
    local line = vim.api.nvim_buf_get_lines(0, lineno - 1, lineno, false)[1]
        or ''
    if string.find(line, '%[ %]') then
        line = line:gsub('%[ %]', '%[x%]')
    else
        line = line:gsub('%[x%]', '%[ %]')
    end
    vim.api.nvim_buf_set_lines(0, lineno - 1, lineno, false, { line })
    vim.api.nvim_win_set_cursor(0, cursor)
    pcall(vim.fn['repeat#set'], ':ToggleCheckbox' .. CR)
end

vim.api.nvim_create_user_command(
    'ToggleCheckbox',
    toggle_checkbox,
    vim.tbl_extend('force', { desc = 'toggle checkboxes' }, {})
)

vim.keymap.set('n', '<leader>ck', toggle_checkbox, {
    noremap = true,
    silent = true,
    desc = 'Toggle checkbox',
    buffer = 0,
})

vim.cmd([[
highlight @unchecked_list_item guifg=#F8F8F2
highlight @checked_list_item guifg=#375749

highlight @text.todo.unchecked guifg=#F8F8F2
highlight @text.todo.checked guifg=#375749
]])
