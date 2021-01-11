lua require 'init'

autocmd FileType markdown,tex set wrap colorcolumn=0
let g:tex_flavor='latex'

" set number
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
set signcolumn=yes
" set colorcolumn=80
set cursorline
" Open splits the _right way_
set splitbelow splitright

let g:python3_host_prog = '~/.pyenv/versions/neovim3/bin/python'

map <Space> <Leader>
nnoremap <leader>ve :edit $MYVIMRC<Enter>
nnoremap <leader>vr :source $MYVIMRC<Enter>

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

nmap <leader>gj :diffget //3<CR>
nmap <leader>gf :diffget //2<CR>
nmap <leader>gs :G<CR>


" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect
" Avoid showing message extra message when using completion
set shortmess+=c

" ===============
" === PLUGINS ===
" ===============
call plug#begin('~/.local/share/nvim/plugged')
" ==========
" === Vi ===
" ==========
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-lua/completion-nvim'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'mhinz/vim-signify'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-fugitive'
    Plug 'google/vim-jsonnet'
    Plug 'mbbill/undotree'
        nnoremap <leader>u :UndotreeShow<CR>
    Plug 'lervag/vimtex'
    Plug 'tpope/vim-markdown'
        let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'json']
    Plug 'vitalk/vim-simple-todo'
    " Plug 'kyazdani42/nvim-web-devicons' " for file icons
    " Plug 'kyazdani42/nvim-tree.lua'
" ==============
" === Python ===
" ==============
    Plug 'jeetsukumaran/vim-pythonsense'
    " Plug 'psf/black', {'for': 'python', 'tag': '19.10b0'}
    Plug 'numirias/semshi'
    Plug 'jpalardy/vim-slime'
        let g:slime_target = "tmux"
        let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
        let g:slime_python_ipython = 0   
    Plug 'wellle/targets.vim'
    Plug 'tmhedberg/SimpylFold'
" ===============
" === Node.js ===
" ===============
    Plug 'prettier/vim-prettier', {
      \ 'do': 'yarn install',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

" ===============
" === WebDev ===
" ===============
    Plug 'alvan/vim-closetag'
        let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
" ===================
" === Coloschemes ===
" ===================
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'arcticicestudio/nord-vim' 
    Plug 'morhetz/gruvbox'
    Plug 'tomasiser/vim-code-dark'
call plug#end()

lua require 'lsp'

set termguicolors 
colorscheme gruvbox
highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=none
" Highligh line number where cursor is
" highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE

" Slime
nmap <c-c><c-c> :SlimeSendCurrentLine<Enter>
nmap <leader>s :SlimeSendCurrentLine<Enter>

" FZF
nmap <Leader>; :Buffers<Enter>
nmap <Leader>t :Files<Enter>
nmap <Leader>c :Commands<Enter>
nmap <Leader>rg :Rg<Enter>
nmap <Leader>h :History:<Enter>
" While searching, Rg shouldn't match file name, only it's content
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgFiles call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -l".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

nmap <C-X> :e #\|bd #<CR>

" Toggles
nnoremap <leader>gc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
nnoremap <silent> <leader>gn :set nu!<CR>
nnoremap <silent> <leader>gg :SignifyToggle<CR>

" BIG QUERIES
    nmap <leader>y :%y+<CR>
    nmap <Leader>bc :!python aydev/bigquery.py check_compilation % <Enter>
    nmap <leader>bs :!python aydev/bigquery.py snapshot % <cword>
    nmap <leader>be :Sexplore %:p:h/snaps/%:p:t:r/  <Enter>

" Search for selection
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Use LSP omni-completion in Python files.
autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

inoremap <expr> <c-x><c-f> fzf#vim#complete#path('fd')
imap <c-x><c-l> <plug>(fzf-complete-line)
inoremap <expr> <c-x><c-k> fzf#vim#complete('cat ~/ay_bin/bq_tables_list.txt')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

