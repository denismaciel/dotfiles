require'nvim-treesitter.configs'.setup {
  ensure_installed = {"python", "go", "javascript", "typescript"},
  highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
  },
  textobjects = {
     move = {
         enable = true,
         set_jumps = true, -- whether to set jumps in the jumplist
         goto_next_start = {
           ["<C-n>"] = "@function.outer",
           ["]]"] = "@class.outer",
         },
         goto_next_end = {
           ["]M"] = "@function.outer",
           ["]["] = "@class.outer",
         },
         goto_previous_start = {
           ["<C-p>"] = "@function.outer",
           ["[["] = "@class.outer",
         },
         goto_previous_end = {
           ["[M"] = "@function.outer",
           ["[]"] = "@class.outer",
         },
    },
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim 
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",

        -- Or you can define your own textobjects like this
        ["iF"] = {
          python = "(function_definition) @function",
        },
      },
    },
  },
}
