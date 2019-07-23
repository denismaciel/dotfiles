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
filetype plugin on
set nocompatible
syntax on

map <Space> <Leader>
inoremap jj <Esc>
" copy current files path to clipboard
nmap cp :let @+ = expand("%") <cr>
nnoremap <leader>ev :edit $MYVIMRC<cr>
" autocmd FileType markdown nnnoremap <buffer> <C-C> !pandoc % -o %:r.pdf
noremap <leader>c :!pandoc % -o %:r.pdf<cr>
noremap <leader>o :!open %:r.pdf<cr>

" set number
set showcmd "show command in bottom bar
" set cursorline
set showmatch "highlight matching parenthesis
set backspace=2 " make backspace work like most other programs

"Search
set incsearch "search as characters are entered
set hlsearch  "highlight matches

noremap J 5j
noremap K 5k

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
" autocmd FileType markdown inoremap ,prf  \succcurlyeq
" autocmd Filetype markdown,rmd inoremap ,a [](<++>)<++><Esc>F[a
" autocmd Filetype text, txt inoremap ,a [](<++>)<++><Esc>F[a

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

Plug 'jalvesaq/Nvim-R'
    let R_assign = 0

Plug 'lervag/vimtex'

Plug 'https://github.com/w0rp/ale.git'
    " let g:ale_python_mypy_executable = 'pipenv'
    " let g:ale_python_pylint_executable = 'pipenv'
    let g:ale_linters = {'python': ['pylint']}
    let g:ale_fixers = {'python': ['black'], 'html': ['prettier'], 'javascript': ['prettier'], 'css': ['prettier'], 'scss': ['prettier']}

Plug 'ambv/black'

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

Plug 'mattn/emmet-vim',  { 'for': ['javascript', 'typescript', 'html'] }

Plug 'mxw/vim-jsx', { 'for': ['javascript', 'typescript', 'html'] }

Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

"" Deoplete
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
" let g:deoplete#enable_at_startup = 1

Plug 'zchee/deoplete-jedi', {'for' : 'python'}
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif "Close documentation buffer automatically

Plug 'junegunn/goyo.vim'

Plug 'Raimondi/delimitMate'

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
" set ttymouse=xterm2
set mouse=a

