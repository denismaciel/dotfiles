" Markdown highlighing for txt files
au BufNewFile,BufFilePre,BufRead *.txt set filetype=markdown
let g:deoplete#enable_at_startup = 1

set tabstop=4 "how many spaces a tab is when vim reads a file
set softtabstop=4 "how many spaces are inserted when you hit tab
set expandtab "tab inserts spaces
set shiftwidth=4
set autoindent
set hidden " switch buffers without saving
set mouse=a
syntax enable "syntax highlighting
filetype plugin on
set nocompatible
syntax on

map <Space> <Leader>
nnoremap <leader>ev :edit $MYVIMRC<cr>
nnoremap <leader>rv :source $MYVIMRC<CR>

" set number
set showcmd "show command in bottom bar
" set cursorline
set showmatch "highlight matching parenthesis
set backspace=2 " make backspace work like most other programs

"Search
set incsearch "search as characters are entered
set hlsearch  "highlight matches

" Copy to Mac's clipboard
set clipboard=unnamed

"Folding 
set foldenable        "enable folding
set foldlevelstart=10 "open most folds by default
set foldmethod=indent

" Treat visual lines as actual lines. 
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

"Rehab
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" prevent scratch buffer from opening on autocompletion
set completeopt-=preview

" === PLUGINS ===
call plug#begin('~/.local/share/nvim/plugged')

Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/goyo.vim'
Plug 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 1   
Plug 'vitalk/vim-simple-todo'
    let g:simple_todo_list_symbol = '-'
Plug 'arcticicestudio/nord-vim' 
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'psf/black'
Plug 'masukomi/vim-markdown-folding'
    " set nocompatible " already set up in the file
    if has("autocmd")
      filetype plugin indent on
    endif
Plug 'Shougo/echodoc.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-unimpaired'
Plug 'jalvesaq/Nvim-R', {'for': 'R'}
call plug#end()
" ==== END PLUG ==== 

" let g:deoplete#enable_at_startup = 1
" let g:deoplete#disable_auto_complete = 1
" inoremap <expr> <C-n>  deoplete#manual_complete()
nmap <c-c><c-c> :SlimeSendCurrentLine <Enter>
" let g:slime_no_mappings = 1

" fzf
nmap ; :Buffers<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>c :Commands<CR>

set cmdheight=2
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'signature'
set signcolumn=yes

nmap <leader>s <Plug>SlimeSendCurrentLine

let R_assign = 2

vmap <leader>p  <Plug>(coc-format-selected)
nmap <leader>p  <Plug>(coc-format)



