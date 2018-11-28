" Markdown highlighing for txt files
au BufNewFile,BufFilePre,BufRead *.txt set filetype=markdown

set tabstop=4 "how many spaces a tab is when vim reads a file
set softtabstop=4 "how many spaces are inserted when you hit tab
set expandtab "tab inserts spaces
set shiftwidth=4
set autoindent
set hidden " switch buffers without saving
"UI
syntax enable "syntax highlighting
colorscheme desert

" vimwiki
filetype plugin on
set nocompatible
syntax on

" copy current files path to clipboard
nmap cp :let @+ = expand("%") <cr>

set number
set showcmd "show command in bottom bar
set cursorline
set showmatch "highlight matching parenthesis
set backspace=2 " make backspace work like most other programs

"Search
set incsearch "search as characters are entered
set hlsearch  "highlight matches

noremap J 5j
noremap K 5k

"Folding 
set foldenable        "enable folding
set foldlevelstart=10 "open most folds by default
set foldmethod=indent

"Navigate Vim panes sanely
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

"Easily navigate buffers
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>

" General shortcuts
    " Go to previous buffer
    nnoremap <leader><leader> <C-^>
    nnoremap <leader>rv :source $MYVIMRC<CR>
    " Same keys for indenting in normal and visual mode
    nnoremap <C-t> >>
    nnoremap <C-d> <<

" Markdown
autocmd FileType markdown inoremap ,prf  \succcurlyeq
autocmd Filetype markdown,rmd inoremap ,a [](<++>)<++><Esc>F[a
autocmd Filetype text, txt inoremap ,a [](<++>)<++><Esc>F[a

"Rehab
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

"Try to fix tmux's different color
set background=dark
set t_Co=256

" === PLUGINS ===
call plug#begin('~/.vim/plugged')

Plug 'https://github.com/w0rp/ale.git'
    let g:ale_python_mypy_executable = 'pipenv'
    let g:ale_python_pylint_executable = 'pipenv'
    let g:ale_linters = {'python': ['pylint']}

Plug 'ambv/black'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
"Markdown
    Plug 'plasticboy/vim-markdown'
        " Activate math syntax extension
        let g:vim_markdown_math = 1
    Plug 'junegunn/vim-easy-align'
        au FileType markdown vmap <Leader>m :EasyAlign*<Bar><Enter>

Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
    nmap ; :Buffers<CR>
    nmap <Leader>t :Files<CR>
    nmap <Leader>r :Tags<CR>
    let $FZF_DEFAULT_COMMAND = 'ag -g ""'    "don't list files in .gitignore

Plug 'tpope/vim-surround'

" Deoplete
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
        let g:deoplete#enable_at_startup = 1

Plug 'zchee/deoplete-jedi'
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif "Closse documentation buffer automatically
Plug 'vimwiki/vimwiki'
Plug 'vim-latex/vim-latex'
" Plug 'Alok/notational-fzf-vim'
" let g:nv_search_paths = ['~/wiki', '~/Dropbox/nVALT-Notes']

call plug#end()

" Treat visual lines as actual lines. 
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

"" Enable mouse inside tmux
set ttymouse=xterm2
set mouse=a
