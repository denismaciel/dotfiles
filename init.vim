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
" set colorcolumn=80
" Open splits the _right way_
set splitbelow
set splitright

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

Plug 'junegunn/vim-easy-align'
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"" Markdown 
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
"" Python
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'psf/black', {'for': 'python', 'tag': '19.10b0'}
Plug 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 0   
Plug 'Shougo/echodoc.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'wellle/targets.vim'
Plug 'google/vim-jsonnet'
Plug 'mbbill/undotree'
    nnoremap <leader>u :UndotreeShow<CR>
Plug 'justinmk/vim-sneak'
    let g:sneak#label = 1
Plug 'lervag/vimtex'
" Coloschemes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'arcticicestudio/nord-vim' 
Plug 'morhetz/gruvbox'
Plug 'tomasiser/vim-code-dark'
Plug 'joshdick/onedark.vim'
Plug 'mhartington/oceanic-next'
call plug#end()

set termguicolors 
colorscheme onedark
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

vmap <leader>p <Plug>(coc-format-selected)
nmap <leader>p <Plug>(coc-format)
nmap <silent> <leader>le <Plug>(coc-diagnostic-display)
nmap <silent> <leader>lp <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>ln <Plug>(coc-diagnostic-next)
nmap <silent> <leader>ld <Plug>(coc-definition)
nmap <silent> <leader>lt <Plug>(coc-type-definition)
nmap <silent> <leader>li <Plug>(coc-implementation)
nmap <silent> <leader>lf <Plug>(coc-references)
nmap <silent> <leader>ls <Plug>(coc-range-select)
nmap <leader>rn <Plug>(coc-rename)

nnoremap <silent> K :call <SID>show_documentation()<Enter>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

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

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
command! LS call fzf#run(fzf#wrap({'source': 'cat ~/file.txt'}))


" " Dim inactive windows using 'colorcolumn' setting
" " This tends to slow down redrawing, but is very useful.
" " Based on https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
" " XXX: this will only work with lines containing text (i.e. not '~')
" function! s:DimInactiveWindows()
"   for i in range(1, tabpagewinnr(tabpagenr(), '$'))
"     let l:range = ""
"     if i != winnr()
"       if &wrap
"         " HACK: when wrapping lines is enabled, we use the maximum number
"         " of columns getting highlighted. This might get calculated by
"         " looking for the longest visible line and using a multiple of
"         " winwidth().
"         let l:width=256 " max
"       else
"         let l:width=winwidth(i)
"       endif
"       let l:range = join(range(1, l:width), ',')
"     endif
"     call setwinvar(i, '&colorcolumn', l:range)
"   endfor
" endfunction
" augroup DimInactiveWindows
"   au!
"   au WinEnter * call s:DimInactiveWindows()
"   au WinEnter * set cursorline
"   au WinLeave * set nocursorline
" augroup END
