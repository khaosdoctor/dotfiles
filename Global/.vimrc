syntax on
colorscheme slate
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
set number

call plug#begin()

    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'scrooloose/syntastic'
    Plug 'nathanaelkane/vim-indent-guides'
    Plug 'sheerun/vim-polyglot'

call plug#end()

set ts=4 sw=4 et
let g:indent_guides_guide_size = 1
