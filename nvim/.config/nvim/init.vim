lua require 'init'

let g:python3_host_prog = '~/venvs/neovim/bin/python'

set tabstop=4 "how many spaces a tab is when vim reads a file
set softtabstop=4 "how many spaces are inserted when you hit tab
set expandtab "tab inserts spaces
set shiftwidth=4
set autoindent
set hidden " switch buffers without saving
set mouse=a
syntax enable 
filetype plugin on
set nocompatible
set nobackup
set noswapfile
set nowrap
set undodir=~/.config/nvim/undodir
set undofile
set showcmd "show command in bottom bar
set showmatch "highlight matching parenthesis
set backspace=2 "make backspace work like most other programs
set incsearch "search as characters are entered
set hlsearch  "highlight matches
set ignorecase smartcase
set clipboard+=unnamedplus
set signcolumn=no
" set colorcolumn=80
set cursorline
" Open splits the _right way_
set splitbelow splitright
set number

map <Space> <Leader>
nnoremap <leader>ve :edit $MYVIMRC<Enter>
nnoremap <leader>vr :source $MYVIMRC<Enter>
nnoremap <leader>vf <cmd>lua require('telescope.builtin').find_files({cwd = '~/.config/nvim/'})<cr>
" Treat visual lines as actual lines. 
nnoremap <silent> k gk
nnoremap <silent> j gj
nnoremap <silent> 0 g0
nnoremap <silent> $ g$
vnoremap <silent> J :m '>+1<CR>gv=gv
vnoremap <silent> K :m '<-2<CR>gv=gv
" Select last pasted text
nnoremap gp `[v`]
" copy whole file to clipboard
nmap <leader>y :%y+<CR> 
" File path to clipboard
nnoremap <leader>fc :!echo -n % \| xclip -selection clipboard<CR>

" Insert dates
nnoremap <leader>fdt "=strftime('%Y-%m-%d %H:%M')<CR>p
nnoremap <leader>fdd "=strftime('%Y-%m-%d')<CR>p
nnoremap <leader>fw "=strftime('%Y-%W')<CR>p
" Copy current buffer's file path to clipbpoard
nnoremap <leader>p :!pre-commit run --file %<CR> :e!<CR>
" Format latex
nnoremap <leader>fp {V}gq<C-O><C-O>
" Search for selection
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup END

nnoremap n nzzzv
nnoremap N Nzzzv

call plug#begin('~/.local/share/nvim/plugged')
    " Checkout eventually: https://github.com/windwp/nvim-autopairs
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'jpalardy/vim-slime'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'machakann/vim-sandwich'
    Plug 'mbbill/undotree'
    Plug 'mhinz/vim-signify'
    Plug 'neovim/nvim-lspconfig'
    Plug 'glepnir/lspsaga.nvim'
    Plug 'nvim-lua/completion-nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'mfussenegger/nvim-dap'
    Plug 'mfussenegger/nvim-dap-python'
    Plug 'tpope/vim-commentary'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'vimwiki/vimwiki'
    Plug 'norcalli/snippets.nvim'
    Plug 'onsails/vimway-lsp-diag.nvim'
    " === Coloschemes ===
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'morhetz/gruvbox'
    " It seems semshi needs to be the last plugin to run...
    Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }
call plug#end()

" ==========================
" ===== Plugins Config =====
" ==========================
lua require 'lsp'
lua require 'treesitter'
lua require 'dap-config'
lua require 'telescope-config'

" Vimwiki
let g:vimwiki_list = [{'path': '~/Sync/vault',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_key_mappings = { 'all_maps': 0, }
nmap <Leader>ww <Plug>VimwikiIndex
nmap <Leader><Enter> <Plug>VimwikiFollowLink
command! SearchNotes lua require'telescope.builtin'.find_files({cwd = "~/Sync/vault"})
nmap <Leader>wfs <cmd> lua require'telescope.builtin'.find_files({cwd = "~/Sync/vault"})<Enter>
nmap <Leader>wfn <cmd> lua require'telescope.builtin'.find_files({cwd = "~/Sync/Notes/Current/"})<Enter>

nnoremap <C-P> <cmd> lua cycle_notes('up')<Enter>
nnoremap <C-N> <cmd> lua cycle_notes('down')<Enter>

" Snippets
lua << EOF
require'snippets'.snippets = {
    _global = {
        todo = [[NOTE(${=io.popen("id -un"):read"*l"}): ]];
        newnote = [[
============
${0}
=----------=
============]];
    }, 

    python = {
        ibed = [[__import__('IPython').embed()]];
    },
    go = {
        iferr = [[if err != nil {
            ${0}
  }]]

    }
}
EOF

command Bd bp | sp | bn | bd

inoremap <tab> <cmd>lua return require'snippets'.expand_or_advance(1)<CR>
inoremap <s-tab> <cmd>lua return require'snippets'.advance_snippet(-1)<CR>

command OpenAnki :e /home/denis/Sync/vault/anki.md

" Folding with treesitter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=99
" 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 1
" 'mbbill/undotree'
    nnoremap <leader>u :UndotreeShow<CR>
" 'nvim-lua/completion-nvim'
    autocmd BufEnter * lua require'completion'.on_attach()
    set completeopt=menuone,noinsert,noselect
    " Avoid showing message extra message when using completion
    set shortmess+=c
    let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy', 'all']
" 'lervag/vimtex'
    let g:tex_flavor='latex'

" ---- Colorscheme ----
set termguicolors 
colorscheme gruvbox
" highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=none
" highlight SignColumn ctermbg=233 ctermfg=233

" ---- Slime ----
nmap <c-c><c-c> :SlimeSendCurrentLine<Enter>

lua << EOF
require('telescope').setup{
    defaults = {
        vimgrep_arguments = {
          'rg',
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
EOF
" ---- FZF ----
nmap <Leader>; <cmd>Telescope buffers<Enter>
nmap <Leader>t <cmd>Telescope find_files<Enter>
nmap <Leader>rg <cmd>Telescope live_grep<Enter>

" ---- Toggles ----
nnoremap <leader>gc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
nnoremap <silent> <leader>gn :set nu!<CR>
nnoremap <silent> <leader>gg :SignifyToggle<CR>

" =======================
" === Language Server ===
" =======================
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gs    <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gtd   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> grn    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gtr    <cmd>Telescope lsp_references<CR>
nnoremap <silent> gtt    <cmd>Telescope tags<CR>
nnoremap <silent> gk <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
nnoremap <silent> gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>
nnoremap <silent><leader>cd <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
nnoremap <silent> <leader>cd :Lspsaga show_line_diagnostics<CR>
nnoremap <silent><leader>cc <cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>
nnoremap <silent> gp <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>
nnoremap <silent> gp <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>
nmap <space>dw <cmd>lua require('vimway-lsp-diag').open_all_diagnostics()<cr>
nmap <space>d0 <cmd>lua require('vimway-lsp-diag').open_buffer_diagnostics()<cr>

" DAP
"
nnoremap <silent> <F5> <cmd>lua require('dap').continue()<CR>
nnoremap <silent> <F9> <cmd>lua require('dap').toggle_breakpoint()<CR>
" {"n", "<F9>"  , [[<cmd>lua require('dap').toggle_breakpoint()<CR>]], opts}
" {"n", "<F10>" , [[<cmd>lua require('dap').step_over()<CR>]], opts}
" {"n", "<F11>" , [[<cmd>lua require('dap').step_into()<CR>]], opts}
" {"n", "<F12>" , [[<cmd>lua require('dap').step_out()<CR>]], opts}


" Use LSP omni-completion in Python files.
autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc

" =========================
" === Utility Functions ===
" =========================
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>
