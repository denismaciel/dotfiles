local me = require 'me'

if me.is_shorts_mode() then
    return {}
end

return {
    {
        'zbirenbaum/copilot.lua',
        config = function()
            require('copilot').setup {
                panel = {
                    enabled = true,
                    auto_refresh = true,
                    keymap = {
                        jump_prev = '[[',
                        jump_next = ']]',
                        accept = '<CR>',
                        refresh = 'gr',
                        open = '<M-CR>',
                    },
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = '<Tab>',
                        next = '<M-N>',
                        prev = '<M-P>',
                        dismiss = '<C-]>',
                    },
                },
                filetypes = {
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ['.'] = false,
                },
                copilot_node_command = 'node', -- Node.js version must be > 16.x
                server_opts_overrides = {},
            }
        end,
    },
    {
        'zbirenbaum/copilot-cmp',
        dependencies = {
            'hrsh7th/nvim-cmp',
            'zbirenbaum/copilot.lua',
        },
        config = function()
            require('copilot_cmp').setup()
        end,
    },
}