set tabstop=4 "how many spaces a tab is when vim reads a file
set softtabstop=4 "how many spaces are inserted when you hit tab
set expandtab "tab inserts spaces
set autoindent
"UI
syntax enable "syntax highlighting
colorscheme codedark

set number
set showcmd "show command in bottom bar
set cursorline
set showmatch "highlight matching parenthesis
set backspace=2 " make backspace work like most other programs

"Search
set incsearch "search as characters are entered
set hlsearch  "highlight matches

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

"Rehab
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

"Try to fix tmux's different color
set background=dark
set t_Co=256

let g:airline_theme='murmur'
" ~/.vim/plugged is where the plugins are going to be installed
call plug#begin('~/.vim/plugged')

" Plug 'vim-syntastic/syntastic'
" Syntastic recommended settings
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" 
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0

Plug 'https://github.com/w0rp/ale.git'
let g:ale_python_mypy_executable = 'pipenv'
let g:ale_python_pylint_executable = 'pipenv'
let b:ale_linters = {'python': ['pylint']}
Plug 'https://github.com/christoomey/vim-tmux-navigator'
Plug 'ambv/black'
Plug 'tmhedberg/SimpylFold' " Python folding
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdcommenter'
"Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
"Distraction-free writing
Plug 'junegunn/goyo.vim'
" Plug 'tpope/vim-fugitive'

" Scars from my attempt to make vim work with IPython
" Plug 'https://github.com/benmills/vimux'
" Plug 'https://github.com/julienr/vim-cellmode'
" Plug 'https://github.com/ivanov/vim-ipython'

" Activate math syntax extension
let g:vim_markdown_math = 1

call plug#end()

" Allow copy paste between vim and tmux
set clipboard=unnamed

" Treat visual lines as actual lines. 
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

