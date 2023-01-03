lua require 'init'

set mouse=a
syntax enable 
filetype plugin on
set clipboard+=unnamedplus
set formatoptions+=cro

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


set laststatus=3
highlight WinSeparator guibg=None
set winbar=%=%m\ %f

nnoremap <leader>asdf :lua package.loaded['me'] = nil<cr>:source $MYVIMRC<cr>
