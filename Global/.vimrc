syntax on
" Set Markdown File Type
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" KeyMaps
" Delete whole word under cursor
nmap <c-w> caw
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
" Close buffer
map gd :bd<CR>
" Navigate through panes
map <c-l> <c-w>l
map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
" Open NerdTree
" map <F2> :NERDTreeToggle<CR>
" Use JSDoc
nmap <silent> <c-j><c-s> <Plug>(jsdoc)
" Fugitive Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gcm :Gcommit<CR>
noremap <Leader>gps :Gpush<CR>
noremap <Leader>gpl :Gpull<CR>
noremap <Leader>gst :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>

" Extension SetUp
set ts=4 sw=4 et

"" Airline
" let g:airline_theme='dark'
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'

" "" NerdTree
" let g:NERDTreeWinSize = 50

" "" JSDoc
" let g:jsdoc_input_description = 1
" let g:jsdoc_additional_descriptions = 1
" let g:jsdoc_access_descriptions = 1
" let g:jsdoc_underscore_private = 1
" let g:jsdoc_enable_es6 = 1

" "" Fugitive
" if exists("*fugitive#statusline")
"   set statusline+=%{fugitive#statusline()}
" endif

" "" Ctrlp
" set wildmode=list:longest,list:full
" set wildignore+=*.o,*.obj,.git
" let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|tox|ico|git|hg|svn))$'
" let g:ctrlp_user_command = "find %s -type f | grep -Ev '"+ g:ctrlp_custom_ignore +"'"
" let g:ctrlp_use_caching = 1
" let g:ctrlp_map = '<c-p>'
" let g:ctrlp_open_new_file = 'r'
" let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'

" " Syntastic
" let g:syntastic_always_populate_loc_list=1
" let g:syntastic_error_symbol='✗'
" let g:syntastic_warning_symbol='⚠'
" let g:syntastic_style_error_symbol = '✗'
" let g:syntastic_style_warning_symbol = '⚠'
" let g:syntastic_auto_loc_list=1
" let g:syntastic_aggregate_errors = 1
" let g:syntastic_javascript_checkers = ['eslint', 'standard']

" General Setup
set updatetime=250
set laststatus=2 " Shows Airline tab bar
set number  " Show line numbers
set relativenumber " Show relative line numbers
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
"set cursorline
highlight CursorColumn ctermbg=Yellow
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
