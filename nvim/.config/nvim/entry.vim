
let g:python3_host_prog = '~/venvs/neovim/bin/python'
set tabstop=4 "how many spaces a tab is when vim reads a file
set softtabstop=4 "how many spaces are inserted when you hit tab
set shiftwidth=4
set autoindent

set mouse=a
syntax enable 
filetype plugin on
set nocompatible
" set nobackup
" set noswapfile
" set nowrap
" set undodir=~/.config/nvim/undodir
" set undofile
set showcmd "show command in bottom bar
set showmatch "highlight matching parenthesis
set backspace=2 "make backspace work like most other programs
" set incsearch "search as characters are entered
" set hlsearch  "highlight matches
" set ignorecase smartcase
set clipboard+=unnamedplus
" set cursorline
set formatoptions+=cro
" Open splits the _right way_
set splitbelow splitright
" set number
" set list lcs=trail:·,tab:»·

au FileType go let b:EditorConfig_disable = 1 
au FileType go setlocal noexpandtab
au FileType markdown setlocal wrap

:cabbrev W w
:cabbrev Wq wq
:cabbrev WQ wq
:cabbrev bd Bd
:cabbrev bd! Bdd
:cabbrev Bd! Bdd

command Bd bp | sp | bn | bd
command Bdd bp! | sp! | bn! | bd!

" https://stackoverflow.com/questions/290465/how-to-paste-over-without-overwriting-register
xnoremap p pgvy

map <Space> <Leader>
nnoremap n nzzzv
nnoremap N Nzzzv
vnoremap < <gv
vnoremap > >gv
nnoremap gp `[v`]
vnoremap <silent> J :m '>+1<CR>gv=gv
vnoremap <silent> K :m '<-2<CR>gv=gv
nnoremap <silent> k gk
nnoremap <silent> j gj
nnoremap <silent> 0 g0
nnoremap <silent> $ g$

" copy whole file to clipboard
nmap <leader>y :%y+<CR> 

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup END

" =================
" ===== Notes =====
" =================
nnoremap <C-P> <cmd> lua cycle_notes('up')<Enter>
nnoremap <C-N> <cmd> lua cycle_notes('down')<Enter>

" Folding with treesitter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99
set foldlevel=99

nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>rp :e playground/p.go<Enter>

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction

set laststatus=3
highlight WinSeparator guibg=None
set winbar=%=%m\ %f " only available in nvim 0.8

nnoremap <leader>asdf :lua package.loaded['me'] = nil<cr>:source $MYVIMRC<cr>
lua require 'init'
