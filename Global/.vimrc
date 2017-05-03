syntax on
" Set Markdown File Type
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" KeyMaps
" Next Tab
map <F8> gt
" Previous tab
map <F7> gT
" Duplicate line down
nmap <c-d> Vyp
" Move to beginning of the line
map <c-h> ^
" Move to end of the line
map <c-l> $
" Go to beginning of the file
map <c-k> gg
" Go to end of the file
map <c-j> G

" Vim-Plug
call plug#begin()

    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'scrooloose/syntastic'
    Plug 'nathanaelkane/vim-indent-guides'
    Plug 'sheerun/vim-polyglot'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'airblade/vim-gitgutter'
    Plug 'ervandew/supertab'
    Plug 'Xuyuanp/nerdtree-git-plugin'

call plug#end()

" Extension SetUp
set ts=4 sw=4 et
let g:indent_guides_guide_size = 1
let g:airline_theme='dark'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" General Setup
set updatetime=250
set laststatus=2 " Shows Airline tab bar
set number  " Show line numbers
set linebreak   " Break lines at word (requires Wrap lines)
set showbreak=+++   " Wrap-broken line prefix
set textwidth=100   " Line wrap (number of cols)
set showmatch   " Highlight matching brace
set visualbell  " Use visual bell (no beeping)
 
set hlsearch    " Highlight all search results
set smartcase   " Enable smart-case search
set ignorecase  " Always case-insensitive
set incsearch   " Searches for strings incrementally
 
set autoindent  " Auto-indent new lines
set smartindent " Enable smart-indent
set smarttab    " Enable smart-tabs
set softtabstop=4   " Number of spaces per Tab
 
set ruler   " Show row and column ruler information
 
set undolevels=1000 " Number of undo levels
set backspace=indent,eol,start  " Backspace behaviour
set ttimeoutlen=50
