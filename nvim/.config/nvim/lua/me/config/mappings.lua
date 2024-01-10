local wk = require('which-key')
local sql = require('me.sql')
local me = require('me')
local zettel = require('me.zettel')
local themes = require('telescope.themes')

vim.keymap.set('n', '<leader>c', '<cmd>ChatGPT<CR>')
vim.keymap.set('n', '<leader>tt', function()
    package.loaded['me'] = nil
    package.loaded['me.sql'] = nil
    vim.api.nvim_command([[ source $MYVIMRC ]])
    require('me.sql').dbt_model_name()
end)

vim.keymap.set('n', '<leader>asdf', function()
    package.loaded['me'] = nil
    vim.api.nvim_command([[ source $MYVIMRC ]])
end)
vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.implementation)
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
vim.keymap.set('n', '0', 'g0')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'gp', '`[v`]')

-- https://stackoverflow.com/questions/290465/how-to-paste-over-without-overwriting-register
vim.keymap.set('x', 'p', 'pgvy')

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '//', [[ y/\V<C-R>=escape(@",'/\')<CR><CR> ]]) --- Search currenlty selected text

vim.cmd('command Bd bp | sp | bn | bd')
vim.cmd('command Bdd bp! | sp! | bn! | bd!')

wk.setup({})
wk.register({
    ['<leader>f'] = { name = 'File' },
    ['<leader>fc'] = {
        ':!echo -n % | xclip -selection clipboard<CR>',
        'Copy file path to clipboard',
    },
    ['<leader>ff'] = { vim.lsp.buf.format, 'Format current buffer' },
    ['<leader>fn'] = { ':call RenameFile()<CR>', 'Rename file' },

    ['<leader>x'] = { name = 'Trouble' },
    ['<leader>xx'] = { '<cmd>TroubleToggle<cr>', 'Toggle' },
    ['<leader>xw'] = {
        '<cmd>TroubleToggle workspace_diagnostics<cr>',
        'Workspace Diagnostics',
    },
    ['<leader>xd'] = {
        '<cmd>TroubleToggle document_diagnostics<cr>',
        'Document Diagnostics',
    },
    ['<leader>xl'] = { '<cmd>TroubleToggle loclist<cr>', 'Loclist' },
    ['<leader>xq'] = { '<cmd>TroubleToggle quickfix<cr>', 'Quickfix' },
    ['<leader>xk'] = { vim.diagnostic.open_float, 'Floating Diagnostics' },

    -- SQL
    ['<leader>s'] = { name = 'SQL' },
    ['<leader>ss'] = {
        ':!sqly snapshot --file % --cte-name <cword> <CR>',
        'Snapshot CTE',
    },
    ['<leader>sx'] = { sql.dbt_open_compiled, 'Open compiled query' },
    ['<leader>sv'] = { sql.dbt_open_snaps, 'Open snapshots' },
    ['<leader>sn'] = {
        ':!echo -n %:t:r | xclip -selection clipboard<CR>',
        'Copy model name to clipboard',
    },
    ['<leader>st'] = {
        function()
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
        end,
        'Find table schema',
    },

    -- Date
    ['<leader>t'] = { name = 'Date' },
    ['<leader>tss'] = {
        [["=strftime('%Y-%m-%d %H:%M')<CR>p]],
        'Insert current timestamp',
    },

    ['<leader>tsd'] = {
        [["=strftime('%Y-%m-%d (%a)')<CR>p]],
        'Insert current time',
    },

    ['<leader>td'] = { require('me').dump_todos, 'Dump TODOs' },

    ['<leader>u'] = { '<cmd>UndotreeToggle<CR>', 'Undotree' },

    ['<leader>a'] = { name = 'Anki' },
})

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
wk.register({
    ['gdd'] = { vim.lsp.buf.declaration, '!! Declaration' },
    ['ga'] = { vim.lsp.buf.code_action, 'Code action' },
    ['gtt'] = {
        function()
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
        end,
        '!! Tags',
    },
    ['gr'] = {
        function()
            require('telescope.builtin').lsp_references(
                require('telescope.themes').get_dropdown({})
            )
        end,
        '!! References',
    },
})

wk.register({
    ['t'] = { name = 'Telescope' },
    ['tt'] = {
        function()
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
        end,
        'Find files',
    },
    ['td'] = {
        function()
            require('telescope.builtin').find_files({
                find_command = { 'git', 'diff', '--name-only', '--relative' },
            })
        end,
        'Find diff files',
    },
    ['tc'] = {
        require('telescope.builtin').commands,
        'Vim Commands',
    },
    ['thi'] = {
        require('telescope.builtin').command_history,
        'Vim Command History',
    },
    ['the'] = {
        require('telescope.builtin').help_tags,
        'Vim Help',
    },
    ['tft'] = {
        require('telescope.builtin').filetypes,
        'FileTypes',
    },
    ['tm'] = {
        require('telescope.builtin').marks,
        'Marks',
    },
    ['tb'] = {
        require('telescope.builtin').current_buffer_fuzzy_find,
        'Buffers',
    },
})

vim.keymap.set('n', '<leader>rg', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>/', require('telescope.builtin').treesitter)
