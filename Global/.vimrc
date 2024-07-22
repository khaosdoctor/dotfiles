syntax on
" Set Markdown File Type
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
" Set i3config File Type
aug i3config_ft_detection
  au!
  au BufNewFile,BufRead *.i3config set filetype=i3config
aug end

" KeyMaps
" Next Tab
map <F8> gt
" Previous tab
map <F7> gT
" Duplicate line down
nmap <c-d> yyp
" Next Buffer
map gn :bn<CR>
" Previous buffer
map gp :bN<CR>
" close buffer
map gd :bd<CR>
" Go to previous cursor position
map go <c-o>
" Go to next cursor position
map gi <c-i>
" Close buffer and return to the previous one without closing the window
map <c-w> :bp<bar>sp<bar>bn<bar>bd<CR>
" Navigate through panes
map <c-l> <c-w>l
map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k

" Extension SetUp
set tabstop=2
set shiftwidth=2
set expandtab " use spaces over tabs

" General Setup
set updatetime=250
set laststatus=2 " Shows Airline tab bar

" Show line numbers as absolute in insert mode and
" auto toggle this to relative when in normal mode
set number
augroup autoToggleRelativeNumbers
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave * if &nu | set nornu | endif
augroup END
" END auto group to change line behaviour

set linebreak   " Break lines at word (requires Wrap lines)
set textwidth=150   " Line wrap (number of cols)
set columns=150
set showmatch   " Highlight matching brace
set visualbell  " Use visual bell (no beeping)
set hlsearch    " Highlight all search results
set smartcase   " Enable smart-case search
set ignorecase  " Always case-insensitive
set incsearch   " Searches for strings incrementally
set cursorcolumn
highlight CursorColumn ctermbg=blue
highlight CursorColumn ctermfg=Black
set colorcolumn=80
set noautoindent  " Auto-indent new lines
set nosmartindent " Enable smart-indent
set nosmarttab    " Enable smart-tabs
set softtabstop=2   " Number of spaces per Tab
set nocindent
filetype indent off
filetype plugin indent off

set ruler   " Show row and column ruler information
set undolevels=1000 " Number of undo levels
set backspace=indent,eol,start  " Backspace behaviour
set ttimeoutlen=50
