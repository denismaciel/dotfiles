return {
    'zk-org/zk-nvim',
    config = function()
        require('zk').setup({
            picker = 'telescope',
        })

        local zk = require('zk')
        local commands = require('zk.commands')

        local create_new_note = function()
            local note_name = vim.fn.input('New note > ')
            if note_name == '' then
                return
            end
            local full_path = '/home/denis/Sync/Notes/Current/'
                .. note_name
                .. '.md'
            vim.cmd('e ' .. full_path)
        end

        local function make_edit_fn(defaults, picker_options)
            return function(options)
                options = vim.tbl_extend('force', defaults, options or {})
                zk.edit(options, picker_options)
            end
        end

        commands.add(
            'ZkRecents',
            make_edit_fn(
                { createdAfter = '4 weeks ago', exclude = 'Anki*' },
                { title = 'Zk Recents' }
            )
        )
        vim.keymap.set(
            'n',
            '<leader>nn',
            [[ <Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>]]
        )
        vim.keymap.set('n', '<leader>nc', function()
            local me = require('me')
            local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
            local line_content = vim.api.nvim_buf_get_text(
                0,
                cursor_line - 1, -- lines are 0-indexed in this function
                0,
                cursor_line - 1,
                -1,
                {}
            )[1]
            local slug = me.slugify(line_content)
            slug = os.date('%Y-%m-%d') .. '-' .. slug
            -- paste to clipboard
            vim.fn.setreg('+', slug)
            vim.print('Copied to clipboard: ' .. slug)
        end)
    end,
}
