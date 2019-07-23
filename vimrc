" Markdown highlighing for txt files
au BufNewFile,BufFilePre,BufRead *.txt set filetype=markdown

set tabstop=4 "how many spaces a tab is when vim reads a file
set softtabstop=4 "how many spaces are inserted when you hit tab
set expandtab "tab inserts spaces
set shiftwidth=4
set autoindent
set hidden " switch buffers without saving
syntax enable "syntax highlighting
filetype plugin on
set nocompatible
syntax on
set showcmd "show command in bottom bar
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

"Navigate Vim panes sanely
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" General shortcuts
    " Go to previous buffer
    map <Space> <Leader>
    nnoremap <leader><leader> <C-^>
    nnoremap <leader>rv :source $MYVIMRC<CR>
    " Same keys for indenting in normal and visual mode
    nnoremap <C-t> >>
    nnoremap <C-d> <<

"Rehab
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" === PLUGINS ===
call plug#begin('~/.vim/plugged')
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
    nmap ; :Buffers<CR>
    nmap <Leader>t :Files<CR>
    nmap <Leader>r :Tags<CR>
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/goyo.vim'
Plug 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 1   
Plug 'vitalk/vim-simple-todo'
    let g:simple_todo_list_symbol = '*'
Plug 'arcticicestudio/nord-vim' 
call plug#end()

" Treat visual lines as actual lines. 
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

"" Enable mouse inside tmux
set mouse=a

