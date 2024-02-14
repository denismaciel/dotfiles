return {
    'nvim-telescope/telescope.nvim',
    dependencies = {},
    config = function()
        local actions = require('telescope.actions')
        local actions_layout = require('telescope.actions.layout')
        local action_state = require('telescope.actions.state')

        local open_in_nvim_tree = function(prompt_bufnr)
            local Path = require('plenary.path')

            local entry = action_state.get_selected_entry()[1]
            local entry_path = Path:new(entry):parent():absolute()
            actions.close(prompt_bufnr)
            entry_path = Path:new(entry):parent():absolute()
            entry_path = entry_path:gsub('\\', '\\\\')

            vim.cmd('NvimTreeClose')
            vim.cmd('NvimTreeOpen ' .. entry_path)

            local file_name = nil
            for s in string.gmatch(entry, '[^/]+') do
                file_name = s
            end

            vim.cmd('/' .. file_name)
        end

        require('telescope').setup({
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
            defaults = {

                mappings = {
                    n = {
                        ['h'] = actions_layout.toggle_preview,
                        ['<c-e>'] = open_in_nvim_tree,
                    },
                    i = {
                        ['<C-h>'] = actions_layout.toggle_preview,
                        ['<c-e>'] = open_in_nvim_tree,
                    },
                },
                path_display = { 'truncate' },
                vimgrep_arguments = {
                    'rg',
                    '--hidden',
                    '--color=never',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                    '--smart-case',
                },
                file_ignore_patterns = {
                    '%.eot',
                    '%.ttf',
                    '%.woff',
                    '%.woff2',
                    '%.parquet',
                    '%.csv',
                },
                layout_config = {
                    width = function(_, max_columns)
                        local percentage = 0.95
                        return math.floor(percentage * max_columns)
                    end,
                    height = function(_, _, max_lines)
                        local percentage = 0.9
                        local min = 70
                        return math.max(math.floor(percentage * max_lines), min)
                    end,
                },
            },
            pickers = {
                buffers = {
                    mappings = {
                        n = {
                            ['dd'] = actions.delete_buffer,
                            ['h'] = actions_layout.toggle_preview,
                        },
                    },
                },
                tags = {
                    mappings = {
                        n = {
                            ['df'] = actions.send_selected_to_qflist
                                + actions.open_qflist,
                        },
                    },
                },
            },
        })

        require('telescope').load_extension('ui-select')
    end,
}
