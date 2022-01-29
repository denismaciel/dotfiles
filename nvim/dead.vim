
call plug#begin('~/.local/share/nvim/plugged')
    Plug 'mfussenegger/nvim-dap'
    Plug 'mfussenegger/nvim-dap-python'
    Plug 'leoluz/nvim-dap-go'
    Plug 'sindrets/diffview.nvim'
    Plug 'folke/twilight.nvim'
call plug#end()


lua require 'dap-config'
lua require('dap-go').setup()
nmap <silent> <leader>dd :lua require('dap-go').debug_test()<CR>
nmap <silent> <leader>dc :lua require('dap-go').continue()<CR>
nmap <silent> <leader>db :lua require('dap-go').toggle_breakpoint()<CR>


lua require 'diffview-config'
lua require('twilight').setup{}
