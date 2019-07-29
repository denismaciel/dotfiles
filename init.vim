" Markdown highlighing for txt files
au BufNewFile,BufFilePre,BufRead *.txt set filetype=markdown

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

" General shortcuts
    " Go to previous buffer
    nnoremap <leader>rv :source $MYVIMRC<CR>
    " Same keys for indenting in normal and visual mode
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

" === PLUGINS ===
call plug#begin('~/.local/share/nvim/plugged')

Plug 'https://github.com/w0rp/ale.git'
    " let g:ale_python_mypy_executable = 'pipenv'
    " let g:ale_python_pylint_executable = 'pipenv'
    let g:ale_linters = {'python': ['pylint']}
    let g:ale_fixers = {'python': ['black'], 'html': ['prettier'], 'javascript': ['prettier'], 'css': ['prettier'], 'scss': ['prettier']}

""Markdown
Plug 'godlygeek/tabular'
" Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
"    " Activate math syntax extension
"    let g:vim_markdown_math = 1

Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
    nmap ; :Buffers<CR>
    nmap <Leader>t :Files<CR>
    nmap <Leader>r :Tags<CR>

Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/goyo.vim'
Plug 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 1   
Plug 'vitalk/vim-simple-todo'
    let g:simple_todo_list_symbol = '*'
Plug 'arcticicestudio/nord-vim' 

