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
syntax on
set smartcase
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
set clipboard+=unnamedplus
set signcolumn=yes
" set colorcolumn=80
" Open splits the _right way_
set splitbelow
set splitright

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
nnoremap <leader>fdt "=strftime('%Y-%m-%d %H:%M (%a)')<CR>p
nnoremap <leader>fdd "=strftime('%Y-%m-%d')<CR>p
nnoremap <leader>fw "=strftime('%Y-%W')<CR>p
nnoremap <leader>k :w<CR>
" Highlight text pasted last
nnoremap gp `[v`] 

nmap <leader>gj :diffget //3<CR>
nmap <leader>gf :diffget //2<CR>
nmap <leader>gs :G<CR>

" prevent scratch buffer from opening on autocompletion
set completeopt-=preview

" === PLUGINS ===
call plug#begin('~/.local/share/nvim/plugged')
Plug 'neovim/nvim-lsp'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/deoplete-lsp'
let g:deoplete#enable_at_startup = 1

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
"" Python
" Plug 'jeetsukumaran/vim-pythonsense'
Plug 'psf/black', {'for': 'python', 'tag': '19.10b0'}
Plug 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 0   
" Plug 'Shougo/echodoc.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'wellle/targets.vim'
Plug 'google/vim-jsonnet'
Plug 'mbbill/undotree'
    nnoremap <leader>u :UndotreeShow<CR>
Plug 'lervag/vimtex'
" Coloschemes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'arcticicestudio/nord-vim' 
Plug 'morhetz/gruvbox'
Plug 'tomasiser/vim-code-dark'
Plug 'joshdick/onedark.vim'
Plug 'mhartington/oceanic-next'
Plug 'fxn/vim-monochrome'
call plug#end()

set termguicolors 
colorscheme gruvbox
highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=none
" Highligh line number where cursor is
highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE

" Slime
nmap <c-c><c-c> :SlimeSendCurrentLine<Enter>
nmap <leader>s :SlimeSendCurrentLine<Enter>

" FZF
nmap <Leader>; :Buffers<Enter>
nmap <Leader>t :Files<Enter>
nmap <Leader>c :Commands<Enter>
nmap <Leader>rg :Rg<Enter>

nmap <C-X> :bp\|bd #<CR>
imap jj <Esc>

" Toggles
nnoremap <leader>gc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
nnoremap <silent> <leader>gn :set nu!<CR>
nnoremap <silent> <leader>gg :SignifyToggle<CR>

" BIG QUERIES
    nmap <leader>y :%y+<CR>
    nmap <Leader>bc :!python dump/check_syntax.py % <Enter>
    nmap <leader>br :!python replace_clip.py \| xclip -selection c<Enter>
    nmap <leader>bs :!python dump/sq_snapshots.py % <cword>
    nmap <leader>be :Sexplore %:p:h/snaps/%:p:t:r/  <Enter>
    nmap <leader>bp :!(xdg-open <cword>.png) & <Enter>

" Python
    nmap <leader>rr  :!python % <Enter>
    nmap <leader>rpt :!tmux send-keys -t right "\%run %" Enter <Enter>

" While searching, Rg shouldn't match file name, only it's content
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Search for selection
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" :packadd nvim-lsp
:lua <<EOF
-- require'nvim_lsp'.jedi_language_server.setup{}
require'nvim_lsp'.dockerls.setup{}
require'nvim_lsp'.pyls.setup{
    settings = {
          pyls = {
            plugins = {
              mccabe = {
                enabled = false;
              };
              flake8 = {
                enabled = false;
              };
              pycodestyle = {
                enabled = false;
              };
              yapf = {
                enabled = false;
              };
              pyls_mypy = {
                enabled = true;
            -- live_mode = false
              };
            }
          }
    }
}
EOF

" Use LSP omni-completion in Python files.
" autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc

nnoremap <silent>gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>K     <cmd>lua vim.lsp.buf.hover()<CR>

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

