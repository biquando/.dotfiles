let mapleader=' '
nnoremap <Space> <Nop>

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-surround'
Plug 'dracula/vim', {'as': 'dracula'}
Plug 'jiangmiao/auto-pairs'
call plug#end()

syntax on                                    " syntax highlighting
filetype plugin indent on                    " language-based indenting
set colorcolumn=81,101                       " highlight columns 81 and 101
set cursorline                               " highlight the current row
set display=uhex                             " show unprintable characters as hex
set hlsearch                                 " highlight matches when searching
set ignorecase                               " ignore case when searching
set list                                     " enable listchars
set listchars=tab:\\x20\\x20,trail:~,nbsp:+  " show trailing spaces and nbsp
set mouse=a                                  " enable mouse control
set ruler                                    " show current cursor position in status bar
set smartcase                                " enable case-sensitive search if uppercase
set termguicolors                            " use true colors (iterm2)
set textwidth=80                             " wrap text at column 80
set timeoutlen=300                           " timeout for leader
set ttimeoutlen=0                            " timeout for keycodes
set updatetime=250                           " write to swap file after this time idle

let g:dracula_colorterm = 0
color dracula

" List & swap buffer
nnoremap <Leader>b :ls<CR>:b<Space>

" Make j and k move by visual lines
nnoremap <expr> j (v:count == 0 ? 'g<down>' : '<down>')
vnoremap <expr> j (v:count == 0 ? 'g<down>' : '<down>')
nnoremap <expr> k (v:count == 0 ? 'g<up>' : '<up>')
vnoremap <expr> k (v:count == 0 ? 'g<up>' : '<up>')

" Use emacs-like Ctrl-B and Ctrl-F in insert mode
inoremap <C-B> <Left>
inoremap <C-F> <Right>

" Set line cursor in insert mode and block cursor in normal mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" File type associations
au BufRead,BufNewFile *.s set ft=arm64
