lua require 'init'

let g:python3_host_prog = '~/venvs/neovim/bin/python'

set completeopt=menu,menuone,noselect
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
set background=dark
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
set signcolumn=no
" set colorcolumn=80
set cursorline
" Open splits the _right way_
set splitbelow splitright
set number
set list lcs=trail:·,tab:»·


au FileType go let b:EditorConfig_disable = 1 
au FileType go setlocal noexpandtab
au FileType markdown setlocal wrap

:cabbrev W w
:cabbrev Wq wq
:cabbrev WQ wq
:cabbrev bd Bd

command Bd bp | sp | bn | bd

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

nnoremap <leader>ve :edit $MYVIMRC<Enter>
nnoremap <leader>vr :source $MYVIMRC<Enter>
nnoremap <leader>vf <cmd>lua require('telescope.builtin').find_files({cwd = '~/.config/nvim/'})<cr>
" copy whole file to clipboard
nmap <leader>y :%y+<CR> 
nnoremap <leader>fc :!echo -n % \| xclip -selection clipboard<CR>
" Insert dates
nnoremap <leader>fdt "=strftime('%Y-%m-%d %H:%M')<CR>p
nnoremap <leader>fdd "=strftime('%Y-%m-%d')<CR>p
nnoremap <leader>fw "=strftime('%Y-%W')<CR>p
nnoremap <leader>p :!pre-commit run --file %<CR> :e!<CR>
" Format latex
nnoremap <leader>fp {V}gq<C-O><C-O>
" Search for selection
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup END

call plug#begin('~/.local/share/nvim/plugged')
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'jpalardy/vim-slime'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'mbbill/undotree'
    Plug 'mhinz/vim-signify'
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'tpope/vim-commentary'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'vimwiki/vimwiki'
    Plug 'onsails/vimway-lsp-diag.nvim'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'ThePrimeagen/harpoon'
    Plug 'windwp/nvim-autopairs'
    Plug 'windwp/nvim-ts-autotag'
    Plug 'ggandor/lightspeed.nvim'
    Plug 'APZelos/blamer.nvim'
    Plug 'neovim/nvim-lspconfig'
    " === Completion ===
    Plug 'hrsh7th/vim-vsnip'
    Plug 'hrsh7th/vim-vsnip-integ'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/nvim-cmp'
    " === Coloschemes ===
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'morhetz/gruvbox'
    Plug 'savq/melange'
    " It seems semshi needs to be the last plugin to run...
    " Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }
call plug#end()

" ==========================
" ===== Plugins Config =====
" ==========================
lua require 'lsp'
lua require 'treesitter'
lua require 'telescope-config'
lua require 'nvim-tree-config'
lua require 'cmp-config'
lua require('nvim-autopairs').setup({})

" =================
" ===== Notes =====
" =================
let g:vimwiki_list = [{'path': '~/Sync/vault',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_key_mappings = { 'all_maps': 0, }
nmap <Leader>ww <Plug>VimwikiIndex
nmap <Leader><Enter> <Plug>VimwikiFollowLink
command! Research lua require'telescope.builtin'.find_files({cwd = "~/Sync/Notes/Current/Research"})
nmap <Leader>wfn <cmd> lua require'telescope.builtin'.find_files({cwd = "~/Sync/Notes/Current/"})<Enter>
command OpenAnki :e /home/denis/Sync/vault/anki.md
nnoremap <C-P> <cmd> lua cycle_notes('up')<Enter>
nnoremap <C-N> <cmd> lua cycle_notes('down')<Enter>

" ===============
" === Harpoon === 
" ===============
nmap <Leader>hh <cmd> lua require("harpoon.ui").toggle_quick_menu()<Enter>
nmap <Leader>ha <cmd> lua require("harpoon.mark").add_file()<Enter>
nmap <Leader>j <cmd> lua require("harpoon.ui").nav_file(1)<Enter>
nmap <Leader>k <cmd> lua require("harpoon.ui").nav_file(2)<Enter>
nmap <Leader>l <cmd> lua require("harpoon.ui").nav_file(3)<Enter>

" Folding with treesitter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=99
" 'jpalardy/vim-slime'
    let g:slime_target = "tmux"
    let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
    let g:slime_python_ipython = 1
" 'mbbill/undotree'
    nnoremap <leader>u :UndotreeShow<CR>

" =======================
" ===== Coloschemes =====
" =======================
set termguicolors 
colorscheme melange
" highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=none
" highlight SignColumn ctermbg=233 ctermfg=233

" ---- Slime ----
nmap <c-c><c-c> :SlimeSendCurrentLine<Enter>

" =====================
" ===== Telescope =====
" =====================
lua << EOF
require('telescope').setup{
    defaults = {
        vimgrep_arguments = {
          'rg',
          '--hiden',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case'
        },
        file_ignore_patterns = {
            "%.eot",
            "%.ttf",
            "%.woff",
            "%.woff2",
        }
    }
}
EOF
nmap <Leader>; <cmd>Telescope buffers<Enter>
nnoremap tt <cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<Enter>
nnoremap tc <cmd>Telescope commands<Enter>
nnoremap th <cmd>Telescope command_history<Enter>
nmap <Leader>rg <cmd>Telescope live_grep<Enter>

" ---- Tree -----
nnoremap tre <cmd>NvimTreeToggle<Enter>

" ---- Toggles ----
nnoremap <silent> <leader>gg :SignifyToggle<CR>

" =======================
" === Language Server ===
" =======================
" Reserved
"     gf
"     gF
"     gv
"     gp

nnoremap <silent> gdd       <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]>     <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD        <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gs        <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gtd       <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr        <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gtr       <cmd>Telescope lsp_references<CR>
nnoremap <silent> grn       <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> g0        <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW        <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gtt       <cmd>Telescope tags theme=dropdown<CR>
nnoremap <silent> K         <cmd>lua vim.lsp.buf.hover()<CR>

nmap <leader>dw             <cmd>lua require('diaglist').open_all_diagnostics()<cr>
nmap <leader>d0             <cmd>lua require('diaglist').open_buffer_diagnostics()<cr>

nnoremap <leader>ff         <cmd>lua vim.lsp.buf.formatting()<cr>

" =========================
" === Utility Functions ===
" =========================
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
