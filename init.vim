" Markdown highlighing for txt files
au BufNewFile,BufFilePre,BufRead *.txt set filetype=markdown

set number
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
syntax on


map <Space> <Leader>
nnoremap <leader>ev :edit $MYVIMRC<Enter>
nnoremap <leader>rv :source $MYVIMRC<Enter>

set showcmd "show command in bottom bar
" set cursorline
set showmatch "highlight matching parenthesis
set backspace=2 " make backspace work like most other programs

"Search
set incsearch "search as characters are entered
set hlsearch  "highlight matches

" Copy to Mac's clipboard
set clipboard=unnamedplus

"Folding 
set foldenable        "enable folding
set foldlevelstart=10 "open most folds by default
set foldmethod=indent

"Rehab
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" prevent scratch buffer from opening on autocompletion
set completeopt-=preview

" === PLUGINS ===
call plug#begin('~/.local/share/nvim/plugged')

Plug 'junegunn/vim-easy-align'
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/goyo.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"" Markdown Stuff
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
    let g:vim_markdown_folding_style_pythonic = 1
Plug 'vitalk/vim-simple-todo'
    let g:simple_todo_list_symbol = '-'

"" Python
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'psf/black', {'for': 'python', 'tag': '19.10b0'}
Plug 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 1   

Plug 'Shougo/echodoc.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'wellle/targets.vim'

" Coloschemes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'arcticicestudio/nord-vim' 
Plug 'ewilazarus/preto'
Plug 'Jorengarenar/vim-darkness'
Plug 'pgdouyon/vim-yin-yang'
Plug 'rakr/vim-two-firewatch'
Plug 'alexanderjeurissen/lumiere.vim'
Plug 'chriskempson/base16-vim'
Plug 'morhetz/gruvbox'
call plug#end()

set termguicolors 
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox

" Highligh line number where cursor is
highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
set cursorline

nmap <c-c><c-c> :SlimeSendCurrentLine<Enter>
nmap <leader>s :SlimeSendCurrentLine<Enter>

" VimWiki
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" FZF
nmap ; :Buffers<Enter>
nmap <Leader>t :Files<Enter>
nmap <Leader>c :Commands<Enter>
nmap <Leader>rg :Rg<Enter>

nmap <C-X> :bd<Enter>
imap jj <Esc>

set cmdheight=2
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'signature'
set signcolumn=yes

vmap <leader>p  <Plug>(coc-format-selected)
nmap <leader>p  <Plug>(coc-format)
nmap <silent> <leader>lp <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>ln <Plug>(coc-diagnostic-next)
nmap <silent> <leader>ld <Plug>(coc-definition)
nmap <silent> <leader>lt <Plug>(coc-type-definition)
nmap <silent> <leader>li <Plug>(coc-implementation)
nmap <silent> <leader>lf <Plug>(coc-references)
nmap <silent> <leader>ls <Plug>(coc-range-select)
nmap <leader>rn <Plug>(coc-rename)

" BIG QUERIES
    nmap <leader>y :%y+<CR>
    nmap <Leader>bc :!python dump/check_syntax.py % <Enter>
    nmap <leader>br :!python replace_clip.py \| xclip -selection c<Enter>
    nmap <leader>bs :!python dump/sq_snapshots.py % <cword>
    nmap <leader>be :Sexplore %:p:h/snaps/%:p:t:r/ 

nnoremap <silent> K :call <SID>show_documentation()<Enter>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Treat visual lines as actual lines. 
nnoremap  <buffer> <silent> k gk
nnoremap  <buffer> <silent> j gj
nnoremap  <buffer> <silent> 0 g0
nnoremap  <buffer> <silent> $ g$
