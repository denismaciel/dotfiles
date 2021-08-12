require'nvim-treesitter.configs'.setup {
  ensure_installed = {"python", "go", "javascript"},
  highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
  },
  textobjects = {
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
