return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-refactor',
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/playground',
    },
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup({
            modules = {},
            sync_install = true,
            ignore_install = {},
            auto_install = true,
            ensure_installed = 'all',
            indent = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    -- init_selection = '+',
                    -- node_incremental = '+',
                    -- node_decremental = '-',
                    init_selection = '<CR>',
                    scope_incremental = '<CR>',
                    node_incremental = '<TAB>',
                    node_decremental = '<S-TAB>',
                },
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
                custom_captures = {
                    ['text.title.1'] = 'ErrorMsg',
                    ['_h1'] = '_h1',
                    ['h2'] = 'h2',
                    ['_h2'] = '_h2',
                    ['h3'] = 'h3',
                    ['_h3'] = '_h3',
                    ['h4'] = 'h4',
                    ['_h4'] = '_h4',
                    ['h5'] = 'h5',
                    ['_h5'] = '_h5',
                },
            },
            textobjects = {
                move = {
                    enable = true,
                    set_jumps = false, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        -- ["<C-n>"] = "@function.outer",
                        [']]'] = '@class.outer',
                        [']a'] = '@parameter.inner',
                    },
                    goto_previous_start = {
                        -- ["<C-p>"] = "@function.outer",
                        ['[['] = '@class.outer',
                        ['[a'] = '@parameter.inner',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']['] = '@class.outer',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[]'] = '@class.outer',
                    },
                },
                select = {
                    enable = true,
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = false,
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                        ['ib'] = '@block.inner',
                        ['ab'] = '@block.outer',
                        ['as'] = '@statment.outer',
                        ['ia'] = '@assignment.inner',
                        ['aa'] = '@assignment.outer',
                    },
                },
            },
        })
    end,
}
