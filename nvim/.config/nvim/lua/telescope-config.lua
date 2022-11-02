local actions = require('telescope.actions')

require('telescope').setup{
    defaults = {
        vimgrep_arguments = {
          'rg',
          '--hidden',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case'
        },
        file_ignore_patterns = {
            "%.eot",
            "%.ttf",
            "%.woff",
            "%.woff2",
        }
    }
}

require('telescope').setup{
  pickers = {
      buffers = {
        mappings = {
            n = {
                ["dd"] = actions.delete_buffer,
            },
            i = {
                -- ["<C-D>"] = actions.delete_buffer,
            }
        }
      }
  },
}
