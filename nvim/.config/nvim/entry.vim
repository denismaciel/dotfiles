lua require 'init'
lua require 'me'

set mouse=a
syntax enable 
filetype plugin on
set nocompatible
set clipboard+=unnamedplus
set formatoptions+=cro
" Open splits the _right way_
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
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=200}
augroup END

" =================
" ===== Notes =====
" =================
nnoremap <C-P> <cmd> lua require("me").cycle_notes('down')<Enter>
nnoremap <C-N> <cmd> lua require("me").cycle_notes('up')<Enter>

" Folding with treesitter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99
set foldlevel=99

nnoremap <leader>u :UndotreeShow<CR>


set laststatus=3
highlight WinSeparator guibg=None
set winbar=%=%m\ %f

nnoremap <leader>asdf :lua package.loaded['me'] = nil<cr>:source $MYVIMRC<cr>
