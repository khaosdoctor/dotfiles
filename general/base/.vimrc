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
" Move blocks of text (linux + Windows)
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
"inoremap <A-j> <Esc>:m .+1<CR>==gi " Insert mode
"inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Move blocks of text (mac
" https://stackoverflow.com/questions/7501092/can-i-map-alt-key-in-vim)
nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
"inoremap ∆ <Esc>:m .+1<CR>==gi " insert mode
"inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

" Extension SetUp
set tabstop=2
set shiftwidth=2
set expandtab " use spaces over tabs
set softtabstop=2   " Number of spaces per Tab

" set default clipboard to system clipboard
set clipboard=unnamed

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
set showmatch   " Highlight matching brace
set visualbell  " Use visual bell (no beeping)
set hlsearch    " Highlight all search results
set smartcase   " Enable smart-case search
set ignorecase  " Always case-insensitive
set incsearch   " Searches for strings incrementally
set cursorcolumn
highlight CursorColumn ctermbg=blue
highlight CursorColumn ctermfg=Black
set colorcolumn=120
set noautoindent  " disable Auto-indent new lines (useful for pasting)
"set nosmartindent " disable Enable smart-indent
"set nosmarttab    " disable Enable smart-tabs
set nocindent
filetype indent off
filetype plugin indent off

set ruler   " Show row and column ruler information
set undolevels=1000 " Number of undo levels
set backspace=indent,eol,start  " Backspace behaviour
set ttimeoutlen=50
