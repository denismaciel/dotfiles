local actions = require('telescope.actions')

require('telescope').setup{
  pickers = {
      buffers = {
        mappings = {
            n = {
                -- ["dd"] = actions.delete_buffer,
            },

            i = {
                ["<C-D>"] = actions.delete_buffer,
            }
        }
      }
  },
}
