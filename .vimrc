set number
set mouse=a
set numberwidth=1
set clipboard=unnamed
syntax enable
set showcmd
set ruler
set cursorline
set showmatch
set sw=4
set relativenumber
set noswapfile
set scrolloff=10
set termguicolors

call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox' " Tema
Plug 'easymotion/vim-easymotion'
Plug 'scrooloose/nerdtree'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()

colorscheme gruvbox
let g:gruvbox_contrast_dark = "hard"
set background=dark
hi Normal guibg=NONE ctermbg=NONE
let NERDTreeQuitOnOpen=1



let mapleader=" "

nmap <Leader>b <Plug>(easymotion-s2)
nmap <Leader>nt :NERDTreeFind<CR>
nmap <Leader>q :q<CR>
nmap <Leader>s :w<CR>
nmap <Leader>x :x<CR>
