local actions = require 'telescope.actions'
local actions_layout = require 'telescope.actions.layout'

require('telescope').setup {
    extensions = {
        ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
        },
    },
    defaults = {
        path_display = { 'smart' },
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
        find_files = {
            mappings = {
                n = {
                    ['h'] = actions_layout.toggle_preview,
                },
            },
        },
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
}

require('telescope').load_extension 'luasnip'
require('telescope').load_extension 'ui-select'
