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

" Plug 'https://github.com/w0rp/ale.git'
"     " let g:ale_python_mypy_executable = 'pipenv'
"     " let g:ale_python_pylint_executable = 'pipenv'
"     let g:ale_linters = {'python': ['pylint']}
"     let g:ale_fixers = {'python': ['black'], 'html': ['prettier'], 'javascript': ['prettier'], 'css': ['prettier'], 'scss': ['prettier']}
Plug 'dracula/vim'
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
    let g:simple_todo_list_symbol = '*'
Plug 'arcticicestudio/nord-vim' 
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'deoplete-plugins/deoplete-jedi'
" Plug 'davidhalter/jedi-vim'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
let g:LanguageClient_serverCommands = {
    \ 'python': ['/Users/dmaciel/.pyenv/versions/3.7.4/bin/pyls']
    \ }

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

Plug 'psf/black' 
Plug 'masukomi/vim-markdown-folding'
    " set nocompatible " already set up in the file
    if has("autocmd")
      filetype plugin indent on
    endif
Plug 'Shougo/echodoc.vim'


call plug#end()
" ==== END PLUG ==== 
"
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
" let g:jedi#completions_enabled = 0
inoremap <expr> <C-n>  deoplete#manual_complete()
nmap <c-c><c-c> :SlimeSendCurrentLine <Enter>
" let g:slime_no_mappings = 1

" fzf
nmap ; :Buffers<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>c :Commands<CR>

call deoplete#custom#source('LanguageClient',
            \ 'min_pattern_length',
            \ 2)

set cmdheight=2
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'signature'
set signcolumn=yes
colorscheme dracula

function SetLSPShortcuts()
  nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
  nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
  nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
  nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
  nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
  nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
  nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
  nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
endfunction()

augroup LSP
  autocmd!
  autocmd FileType python call SetLSPShortcuts()
augroup END


nmap <leader>s <Plug>SlimeSendCurrentLine
