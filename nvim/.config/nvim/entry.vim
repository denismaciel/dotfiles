lua require 'init'

set clipboard+=unnamedplus
set formatoptions+=cro

command Bd bp | sp | bn | bd
command Bdd bp! | sp! | bn! | bd!

map <Space> <Leader>

vnoremap < <gv
vnoremap <silent> J :m '>+1<CR>gv=gv
vnoremap <silent> K :m '<-2<CR>gv=gv
vnoremap > >gv
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
