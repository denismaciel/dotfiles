local dennich = require('dennich')

-- local function smart_paste(register)
--     register = register or '+'
--     local clipboard_content = vim.fn.getreg(register)
--     if dennich.is_url(clipboard_content) then
--         local formatted_text = '[](' .. clipboard_content .. ')'
--         vim.api.nvim_put({ formatted_text }, '', false, true)
--         -- Move cursor to the closing bracket using F]
--         local keys = vim.api.nvim_replace_termcodes('F]', true, false, true)
--         vim.api.nvim_feedkeys(keys, 'n', false)
--     else
--         local keys = vim.api.nvim_replace_termcodes('p', true, false, true)
--         vim.api.nvim_feedkeys(keys, 'n', false)
--     end
-- end

local augroup =
    vim.api.nvim_create_augroup('CustomizeMarkdown', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        vim.api.nvim_buf_set_option(0, 'expandtab', true)
        vim.api.nvim_buf_set_option(0, 'shiftwidth', 2)
        vim.api.nvim_buf_set_option(0, 'tabstop', 2)
        vim.api.nvim_buf_set_option(0, 'wrap', true)
        vim.api.nvim_buf_set_option(0, 'conceallevel', 0)

        -- Disabled: regular paste preferred over auto-formatting URLs into markdown links
        -- vim.keymap.set('n', 'p', function()
        --     smart_paste('+')
        -- end, { buffer = true, desc = 'Smart paste for URLs in markdown' })
        -- vim.keymap.set('v', 'p', function()
        --     smart_paste('+')
        -- end, { buffer = true, desc = 'Smart paste for URLs in markdown' })

        vim.api.nvim_create_user_command('Was', function(opts)
            vim.cmd('write' .. (opts.bang and '!' or ''))
            if vim.bo.filetype == 'markdown' then
                vim.api.nvim_echo({
                    {
                        ' 🙉 Markdown is saved automatically! 🙉',
                        'WarningMsg',
                    },
                }, false, {})
            end
        end, { bang = true })
        vim.cmd('cabbrev w Was')
        vim.cmd('cabbrev w! Was!')
    end,
    group = augroup,
    pattern = { '*.md', '*.txt' },
})

vim.keymap.set('n', '<C-N>', function()
    require('dennich').cycle_notes('up')
end, { buffer = 0 })

vim.keymap.set('n', '<C-P>', function()
    require('dennich').cycle_notes('down')
end, {
    buffer = 0,
})

-- Toggle checkboxes
-- Copied from:
-- https://github.com/caarlos0/dotfiles/blob/c2b002dda2329d82d1e8ffd454c8e7957ae6cc75/modules/neovim/config/after/ftplugin/markdown.lua
local CR = vim.api.nvim_replace_termcodes('<cr>', true, true, true)
local function toggle_checkbox()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local lineno = cursor[1]
    local line = vim.api.nvim_buf_get_lines(0, lineno - 1, lineno, false)[1]
        or ''

    -- Check if line has a checkbox
    if string.find(line, '%[ %]') then
        -- Toggle unchecked to checked
        line = line:gsub('%[ %]', '%[x%]')
        vim.api.nvim_buf_set_lines(0, lineno - 1, lineno, false, { line })
        vim.api.nvim_win_set_cursor(0, cursor)
        pcall(vim.fn['repeat#set'], ':ToggleCheckbox' .. CR)
    elseif string.find(line, '%[x%]') then
        -- Toggle checked to unchecked
        line = line:gsub('%[x%]', '%[ %]')
        vim.api.nvim_buf_set_lines(0, lineno - 1, lineno, false, { line })
        vim.api.nvim_win_set_cursor(0, cursor)
        pcall(vim.fn['repeat#set'], ':ToggleCheckbox' .. CR)
    else
        -- No checkbox found, insert one at the beginning and enter insert mode
        -- Preserve indentation if any
        local indentation = line:match('^%s*')
        local new_line = indentation .. '- [ ] ' .. line:gsub('^%s*', '')
        vim.api.nvim_buf_set_lines(0, lineno - 1, lineno, false, { new_line })

        -- Position cursor at the end of "- [ ] " after the indentation
        local new_col = #indentation + 6
        vim.api.nvim_win_set_cursor(0, { lineno, new_col })

        -- Enter insert mode
        vim.cmd('startinsert')
    end
end

vim.api.nvim_create_user_command(
    'ToggleCheckbox',
    toggle_checkbox,
    vim.tbl_extend('force', { desc = 'toggle checkbox' }, {})
)

vim.keymap.set('n', '<leader>ck', toggle_checkbox, {
    noremap = true,
    silent = true,
    desc = 'Toggle checkbox',
    buffer = 0,
})

-- local function highlights()
--     vim.api.nvim_set_hl(0, '@unchecked_list_item', { fg = '#F8F8F2' })
--     vim.api.nvim_set_hl(0, '@checked_list_item', { fg = '#375749' })
--     vim.api.nvim_set_hl(0, '@text.todo.unchecked', { fg = '#F8F8F2' })
--     vim.api.nvim_set_hl(0, '@text.todo.checked', { fg = '#375749' })
-- end
--
-- -- Apply the highlighting on buffer read and window enter
-- vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWinEnter' }, {
--     callback = highlights,
--     group = augroup,
-- })
