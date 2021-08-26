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

map <Space> <Leader>
nnoremap <leader>ve :edit $MYVIMRC<Enter>
nnoremap <leader>vr :source $MYVIMRC<Enter>
nnoremap <leader>vf :Files ~/.config/nvim/<Enter>
" Treat visual lines as actual lines. 
nnoremap <silent> k gk
nnoremap <silent> j gj
nnoremap <silent> 0 g0
nnoremap <silent> $ g$
vnoremap <silent> J :m '>+1<CR>gv=gv
vnoremap <silent> K :m '<-2<CR>gv=gv
" Select last pasted text
nnoremap gp `[v`]
nnoremap <leader>fdt "=strftime('%Y-%m-%d %H:%M')<CR>p
nnoremap <leader>fdd "=strftime('%Y-%m-%d')<CR>p
nnoremap <leader>fw "=strftime('%Y-%W')<CR>p
" Copy current buffer's file path to clipbpoard
nnoremap <leader>fc :!echo % \| xclip -selection clipboard<CR>
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
    Plug 'google/vim-jsonnet'
    Plug 'jpalardy/vim-slime'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    " Plug 'lervag/vimtex'
    Plug 'machakann/vim-sandwich'
    Plug 'mbbill/undotree'
    Plug 'mhinz/vim-signify'
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-lua/completion-nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'tpope/vim-commentary'
    Plug 'editorconfig/editorconfig-vim'
    " === Coloschemes ===
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'ray-x/aurora'      " for Plug user
    Plug 'morhetz/gruvbox'
    " It seems semshi needs to be the last plugin to run...
    Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }
    Plug 'tjdevries/colorbuddy.vim'
    Plug 'Th3Whit3Wolf/spacebuddy'
    Plug 'marko-cerovac/material.nvim'
call plug#end()

" ==========================
" ===== Plugins Config =====
" ==========================
lua require 'lsp'
lua require 'treesitter'


" Folding with treesitter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
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
" colorscheme aurora
" lua require('colorbuddy').colorscheme('spacebuddy')
:lua vim.g.material_style = "deep ocean"
colorscheme material
" highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=none
" highlight SignColumn ctermbg=233 ctermfg=233

" ---- Slime ----
nmap <c-c><c-c> :SlimeSendCurrentLine<Enter>

" ---- FZF ----
nmap <Leader>; :Buffers<Enter>
nmap <Leader>t :GFiles<Enter>
nmap <Leader>c :Commands<Enter>
nmap <Leader>rg :Rg<Enter>
command! -bang -nargs=? GFiles call fzf#vim#gitfiles(<q-args>, {'options': '--no-preview'}, <bang>0)
" While searching, Rg shouldn't match file name, only it's content
command! -bang -nargs=* Rg call fzf#vim#grep("rg -g '!*archived*' --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgFiles call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -l".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('fd')
imap <c-x><c-l> <plug>(fzf-complete-line)

" ---- Toggles ----
nnoremap <leader>gc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
nnoremap <silent> <leader>gn :set nu!<CR>
nnoremap <silent> <leader>gg :SignifyToggle<CR>

cabbrev <expr> YMD strftime("%Y-%W")
nmap <leader>d :e ~/Sync/Notes/Current/Work-YMD.md<CR>
" ---- BIG QUERIES ----
nmap <leader>y :%y+<CR>
nmap <Leader>bc :!python aydev/bigquery.py check_compilation % <Enter>
nmap <Leader>bf :!python aydev/bigquery.py whole_query % <Enter>
nmap <leader>bs :!python -m aymario.bigquery snapshot % <cword>
nmap <leader>be :Sexplore %:p:h/snaps/%:p:t:r/  <Enter>

" =======================
" === Language Server ===
" =======================
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
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
