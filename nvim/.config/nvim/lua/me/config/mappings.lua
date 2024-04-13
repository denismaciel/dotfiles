local wk = require('which-key')
local sql = require('me.sql')
local me = require('me')
local themes = require('telescope.themes')

-- Stolen from https://github.com/tjdevries/config_manager/blob/ee11710c4ad09e0b303e5030b37c86ad8674f8b2/xdg_config/nvim/lua/tj/lsp/handlers.lua#L30
local implementation = function()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(
        0,
        'textDocument/implementation',
        params,
        function(err, result, ctx, config)
            local bufnr = ctx.bufnr
            local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

            -- In go code, I do not like to see any mocks for impls
            if ft == 'go' then
                local new_result = vim.tbl_filter(function(v)
                    return not string.find(v.uri, '_mock')
                end, result)

                if #new_result > 0 then
                    result = new_result
                end
            end

            vim.lsp.handlers['textDocument/implementation'](
                err,
                result,
                ctx,
                config
            )
            vim.cmd([[normal! zz]])
        end
    )
end

wk.setup({})
wk.register({
    ['t'] = { name = 'Telescope' },
    ['<leader>f'] = { name = 'File' },
    ['<leader>x'] = { name = 'Trouble' },
    ['<leader>s'] = { name = 'SQL' },
    ['<leader>t'] = { name = 'Date' },
    ['<leader>a'] = { name = 'Anki' },
})

vim.keymap.set('n', '<leader>tt', function()
    package.loaded['me'] = nil
    package.loaded['me.sql'] = nil
    vim.api.nvim_command([[ source $MYVIMRC ]])
    require('me.sql').dbt_model_name()
end)

vim.keymap.set('n', '<leader>asdf', function()
    package.loaded['me'] = nil
    vim.api.nvim_command([[ source $MYVIMRC ]])
    print('reloaded myvimrc')
end)
vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', implementation)
vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
vim.keymap.set('n', 'grn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>;', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeFindFileToggle<CR>')
vim.keymap.set(
    'v',
    '<leader>tm',
    ':!pandoc --to html | xclip -t text/html -selection clipboard<cr>u'
)
vim.keymap.set('n', '$', 'g$')
vim.keymap.set('n', '<c>o', '<c>ozz')
vim.keymap.set('n', '<c>]', '<c>]zz')
vim.keymap.set('n', '0', 'g0')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'gp', '`[v`]')
vim.keymap.set('x', 'p', 'pgvy') -- https://stackoverflow.com/questions/290465/how-to-paste-over-without-overwriting-register
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '//', [[ y/\V<C-R>=escape(@",'/\')<CR><CR> ]]) --- Search currenlty selected text
vim.cmd('command Bd bp | sp | bn | bd')
vim.cmd('command Bdd bp! | sp! | bn! | bd!')
vim.keymap.set(
    'n',
    '<leader>fc',
    ':!echo -n % | xclip -selection clipboard<CR>',
    { desc = 'Copy file path to clipboard' }
)
vim.keymap.set(
    'n',
    '<leader>ff',
    vim.lsp.buf.format,
    { desc = 'Format current buffer' }
)
vim.keymap.set(
    'n',
    '<leader>fn',
    ':call RenameFile()<CR>',
    { desc = 'Rename file' }
)
vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>', { desc = 'Toggle' })
vim.keymap.set(
    'n',
    '<leader>xw',
    '<cmd>TroubleToggle workspace_diagnostics<cr>',
    { desc = 'Workspace Diagnostics' }
)
vim.keymap.set(
    'n',
    '<leader>xd',
    '<cmd>TroubleToggle document_diagnostics<cr>',
    { desc = 'Document Diagnostics' }
)
vim.keymap.set(
    'n',
    '<leader>xl',
    '<cmd>TroubleToggle loclist<cr>',
    { desc = 'Loclist' }
)
vim.keymap.set(
    'n',
    '<leader>xq',
    '<cmd>TroubleToggle quickfix<cr>',
    { desc = 'Quickfix' }
)
vim.keymap.set(
    'n',
    '<leader>xk',
    vim.diagnostic.open_float,
    { desc = 'Floating Diagnostics' }
)

vim.keymap.set(
    'n',
    '<leader>ss',
    ':!sqly snapshot --file % --cte-name <cword> <CR>',
    { desc = 'Snapshot CTE' }
)
vim.keymap.set(
    'n',
    '<leader>sx',
    sql.dbt_open_compiled,
    { desc = 'Open compiled query' }
)
vim.keymap.set('n', '<leader>sr', sql.dbt_open_run, { desc = 'Open run query' })
vim.keymap.set(
    'n',
    '<leader>sv',
    sql.dbt_open_snaps,
    { desc = 'Open snapshots' }
)
vim.keymap.set(
    'n',
    '<leader>sn',
    ':!echo -n %:t:r | xclip -selection clipboard<CR>',
    { desc = 'Copy model name to clipboard' }
)
vim.keymap.set('n', '<leader>st', function()
    require('telescope.builtin').find_files({
        find_command = {
            'rg',
            '--files',
            '--hidden',
            '-g',
            '!.git',
            '-g',
            '!.snapshots/',
        },
        cwd = '/home/denis/.cache/recap/bigquery-schema/',
    })
end, { desc = 'Find table schema' })

vim.keymap.set(
    'n',
    '<leader>tss',
    [["=strftime('%Y-%m-%d %H:%M')<CR>pI### <Esc>o<Enter>]],
    { desc = 'Insert current timestamp' }
)
vim.keymap.set(
    'n',
    '<leader>tsd',
    [["=strftime('%Y-%m-%d (%a)')<CR>p]],
    { desc = 'Insert current time' }
)

vim.keymap.set(
    'n',
    '<leader>u',
    '<cmd>UndotreeToggle<CR>',
    { desc = 'Undotree' }
)

vim.keymap.set('n', '<leader>ao', function()
    me.find_anki_notes(require('telescope.themes').get_dropdown({}))
end, { desc = 'Find Anki note' })

vim.keymap.set({ 'n' }, '<leader>ao', function()
    me.find_anki_notes(require('telescope.themes').get_dropdown({}))
end, {
    desc = 'Find Anki note',
})

vim.keymap.set({ 'n' }, '<leader>ae', function()
    me.anki_edit_note()
end, {
    desc = 'Edit Anki note',
})

vim.keymap.set('n', 'gdd', vim.lsp.buf.declaration, { desc = 'Declaration' })
vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('n', 'gtt', function()
    local opts = themes.get_dropdown({})
    local layout_config = {
        width = 0.9,
        height = 0.6,
        horizontal = {
            width = { padding = 0.15 },
        },
        vertical = {
            preview_height = 0.75,
        },
    }
    opts.layout_config = layout_config
    opts.fname_width = 70
    require('telescope.builtin').tags(opts)
end, { desc = 'Tags' })
vim.keymap.set('n', 'gr', function()
    require('telescope.builtin').lsp_references(
        require('telescope.themes').get_dropdown({})
    )
end, { desc = 'References' })
vim.keymap.set('n', 'tt', function()
    require('telescope.builtin').find_files({
        find_command = {
            'rg',
            '--files',
            '--hidden',
            '-g',
            '!.git',
            '-g',
            '!.snapshots/',
        },
    })
end, { desc = 'Find files' })
vim.keymap.set('n', 'td', me.insert_text, { desc = 'Insert block of text' })
vim.keymap.set(
    'n',
    'tc',
    require('telescope.builtin').commands,
    { desc = 'Vim Commands' }
)
vim.keymap.set(
    'n',
    'thi',
    require('telescope.builtin').command_history,
    { desc = 'Vim Command History' }
)
vim.keymap.set(
    'n',
    'the',
    require('telescope.builtin').help_tags,
    { desc = 'Vim Help' }
)
vim.keymap.set(
    'n',
    'tft',
    require('telescope.builtin').filetypes,
    { desc = 'FileTypes' }
)
vim.keymap.set(
    'n',
    'tm',
    require('telescope.builtin').marks,
    { desc = 'Marks' }
)
vim.keymap.set(
    'n',
    'tb',
    require('telescope.builtin').current_buffer_fuzzy_find,
    { desc = 'Buffers' }
)
vim.keymap.set('n', '<leader>rg', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>/', require('telescope.builtin').treesitter)
