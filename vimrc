" vim:sw=4:expandtab:tw=120

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
    finish
endif

let s:short_hostname = substitute(hostname(), '\..*', '', '')
let g:is_dev_host = v:version >= 901 && $USER != 'root'

""""""""""""""""""""""""""""
" When using KDE konsole:
" Edit ~/.kde/share/apps/konsole/default.keytab: find the line:
" key Right-Shift+Ansi+AnyModifier : "\E[1;*C"
" and remove "-Shift". Do the same for "Left". You can also change it in
" konsole settings.
"
" Hint: '*' in key output is substitued with a number depending on modifier
" keys pressed. For information on the codes see keytrans.{cpp,h} from konsole
" sources.

""""""""""""""""""""""""""""
" most options settings go here

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Keep swap file in a given directory (multiple can be given). We don't want "." here, as swap files hanging around can
" fool Bazel into rebuilding everything if it's a file in sysroot.
" "//" means swap file name will be built from the complete path to the file.
set directory=/tmp//

" time out on mapping after three seconds, time out on key codes after a tenth of a second
set timeout timeoutlen=3000 ttimeoutlen=100

" <leader> is by default mapped to \
"let mapleader = "\<space>"

" Reasonable text/indent settings for most projects and scripts. For specific projects use autocommands.
set shiftwidth=4
set ts=4
set noexpandtab
set textwidth=120

" Whether to keep recommended style for python projects. If this is 1 (which is the default) then
" $VIMRUNTIME/ftplugin/python.vim applies PEP8 settings for python buffers.
" ostTesting
" Below are used by a function in 'indentexpr' option for python files. Note that this function is loaded lazily, only
" after you insert some text.
let g:python_recommended_style=0
let g:python_indent = {}
let g:python_indent.open_paren = 'shiftwidth()'
let g:python_indent.nested_paren = 'shiftwidth()'
let g:python_indent.continue = 'shiftwidth()'
let g:python_indent.closed_paren_align_last_line = v:false

" Workaround for some python2 modules getting imported by ycmd (python3).
let $PYTHONPATH = ''

" don't indent C++ class/struct scope declarations (public, protected, private)
" don't indent switch case labels
set cinoptions=g0,:0

" For :find to search recursively in current dir.
set path+=**

set backspace=indent,eol,start   " backspace over everything in insert mode
set autoindent                   " always set autoindenting on
set nobackup                     " do not keep a backup file, use versions instead
set history=1000                 " keep X lines of command line history
" Actually if statusline is not empty (see TagbarToggle) then ruler is not visible.
set ruler                        " show the cursor position all the time
set laststatus=2                 " always display statusline (even if one window)
set number                       " line numbering
set updatetime=100               " in ms
set showcmd                      " display incomplete commands
set incsearch                    " do incremental searching
set showmatch
set completeopt=preview,menuone
if has('textprop')
    " use popup rather than preview
    set completeopt-=preview
    set completeopt+=popup
endif
set hidden
" save/restore uppercase global variables (for :Hsave/Hrestore from highlights plugin)
"set viminfo^=!
set fileencodings=ucs-bom,utf-8,latin2
set scrolloff=7
" After a couple of "jump back" (ctrl-o), when we make another jump, vim discards newer jumps, which is more reasonable
" than the default behavior in which it keeps them. It makes more sense when doing code exploration, with frequently
" jumping to function definitions and then going back. With "stack" it indeed goes back.
if v:version >= 901
    set jumpoptions=stack
endif

" Disable cursorline:
" * it causes slight confusion: it is in every window, so every window looks like active (yeah, one needs to look at
"   statusline)
" * it does not play well with diff highlighting
"set cursorline
" Instead enable it in current window only, except it is disabled:
" * in diff mode - diff highlighting changes background color, but not foreground
" * in nerdtree window, as a workaround for the following issue: when hitting Enter on a file, it doesn't trigger
"   WinLeave and &cursorline is kept set in nerdtree window even though it is no longer the current window
" * in other unlisted buffers, such as vim-ctrlspace window, but enable it for vim help and man buffers
function! s:SetCursorLine()
    if &diff || ( ! &buflisted && &filetype != "help"  && &filetype != "man" )
        set nocursorline
    else
        set cursorline
    endif
endfunction

augroup CursorLine
    autocmd!
    autocmd WinLeave * set nocursorline
    " WinEnter is not done for the first window, when Vim has just started. Another event must be used:
    " - VimEnter: this solves the issue, but it does not work when opening a file using nerdtree.
    " - BufWinEnter: solves both issues. From docs: "after a buffer is displayed in a window".
    autocmd WinEnter,BufWinEnter * call <SID>SetCursorLine()
    autocmd OptionSet diff,filetype call <SID>SetCursorLine()
augroup END

set diffopt+=vertical
if v:version >= 802
    set relativenumber               " relative line numbering
    set diffopt+=algorithm:patience
    set diffopt+=indent-heuristic
    " commented out: let's not use inline:word for now, as it doesn't work very well
    "if index(split(&diffopt, ","), "inline:simple") != -1
    "    set diffopt-=inline:simple
    "    set diffopt+=inline:word
    "endif
endif
if v:version >= 901
    " If someone comments out a lot of lines with # or // comments, then this setting makes Vim highlight only the
    " comment sign as changed (needs 'inline' option too).
    set diffopt+=linematch:300
endif

set nowrap

set splitright
"set splitbelow

if &term == "screen" || &term == "screen-bce" || &term == "screen.xterm-256color" || &term == "xterm" || &term == "xterm-color" || &term == "xterm-256color" || &term == "screen-256color-fixed" || &term == "tmux-256color"
    set title
endif

set background=dark " terminal background: dark or light

" This shouldn't be needed anymore.
"if &term == "screen-bce" || &term == "screen.xterm-256color" || &term == "xterm" || &term == "xterm-color" || &term == "xterm-256color"
"    set t_Co=256
"endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on " must be done before any other :syntax calls
    set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " recognize more file types
    autocmd BufNewFile,BufRead *.[rR] set filetype=r
    autocmd BufNewFile,BufRead *.jcl set filetype=jcl
    autocmd BufNewFile,BufRead *.arff set filetype=arff
    autocmd BufNewFile,BufRead strace.*[0123456789] set filetype=strace
    autocmd BufNewFile,BufRead *.strace set filetype=strace
    autocmd BufNewFile,BufRead *.ts set filetype=javascript
    autocmd BufNewFile,BufRead *.rdl set filetype=systemrdl

    " add an option to wrap long lines during inserting, because it gets deleted
    " in a C indent plugin
    autocmd FileType c,cpp,sh,text,tex setlocal formatoptions+=t

    " don't leave one-letter word at the end of a line (Polish typographical rule)
    autocmd FileType text setlocal formatoptions+=1

    " comment begin with ';'
    autocmd FileType asm,avr setlocal comments+=b:;

    " make letters and '@' keyword characters ('@' for LaTeX)
    " FIXME: don't add '@' for plain TeX
    autocmd FileType tex setlocal iskeyword=@,@-@

    " To facilitate search for word under cursor if package name contains colons.
    autocmd FileType perl setlocal iskeyword-=:

    " highlighting of \begin{comment} ... \end{comment} for LaTeX
    autocmd FileType tex syntax region verbatimComment start="\\begin{comment}" end="\\end{comment}" fold
    autocmd FileType tex hi def link verbatimComment Comment

    autocmd FileType gitcommit setlocal textwidth=120

    " Kernel code
    autocmd BufRead,BufNewFile *repos/linux/*.h set filetype=c

    " Python projects (see g:python_recommended_style)
    " obsoleted by vim-sleuth
    "autocmd FileType python if expand('%:p') =~ 'YouCompleteMe' | setlocal expandtab sw=2 ts=2 | endif

    " set b:match_words for matchit/vim-matchup plugin
    " Disabled: $VIMRUNTIME/ftplugin/make.vim already sets this.
    "autocmd FileType make let b:match_words = '\<ifn\?\(eq\|def\)\>:\<else\>:\<endif\>,\<define\>:\<endef\>'

    " From https://www.reddit.com/r/vim/comments/7c1rjd/matchup_a_modern_enhanced_matchit_replacement/
    " > In short, match-up will only move between "words" which are:
    " >
    " > a) defined in the file type's b:match_words (and thus supported by match-it) and
    " >
    " > b) have a definite "end word." Here, "words" means "symbols or words," e.g., { is a word.
    " >
    " > In C/C++, blocks are delimited by { ... }, not if ... end. In python,
    " > blocks are specified by indentation, so I don't support that yet. Currently,
    " > match-up will match anything that matchit supports (but with many
    " > enhancements), but it's still using the same b:match_words.
    " Disabled: it matches 'else' with unrelated 'if' (more nested) occuring ealier.
    "autocmd FileType python let b:match_words = '\<if\>:\<elif\>:\<else\>,\<try\>:\<except\>'
    " Note: jumping with % seems to be supported in neovim through treesitter:
    " *g:matchup_matchparen_end_sign*
    "
    "   (neovim only) Configure the virtual symbol shown for closeless matches in languages like
    "   C++ and python.
    "
    "       if (true)
    "         cout << "";
    "       else
    "         cout << ""; ◀ if
    "
    "   Default: ◀

    " macros in makefiles ('define' keyword) usually have '-' in their names
    autocmd FileType make setlocal iskeyword+=-
    " same for .yml files
    autocmd FileType yaml setlocal iskeyword+=-

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    "autocmd BufReadPost *
    "\ if line("'\"") > 0 && line("'\"") <= line("$") |
    "\   exe "normal g`\"" |
    "\ endif
    " This one is newer, from Vim's help:
    augroup RestoreCursor
      autocmd!
      autocmd BufReadPost *
        \ let line = line("'\"")
        \ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
        \      && index(['xxd', 'gitrebase'], &filetype) == -1
        \ |   execute "normal! g`\""
        \ | endif
    augroup END

    " When switching windows (or tabs), sometimes there is a stale message in the command line, for example showing a
    " file name from another window. Clear it when switching.
    autocmd WinLeave * echon ''
endif " has("autocmd")

""""""""""""""""""""""""""""
" Fixes for GNU screen.

if &term == "screen" || &term == "screen-bce" || &term == "screen-256color" || &term == "screen-256color-fixed"
    set <s-left>=[1;2D
    set <s-right>=[1;2C
    set <s-up>=[1;2A
    set <s-down>=[1;2B

    set <f13>=[1;5D
    set <f14>=[1;5C
    set <f15>=[1;5A
    set <f16>=[1;5B
    set <f17>=[5;5~
    set <f18>=[6;5~
    map <f13> <c-left>
    map <f14> <c-right>
    map <f15> <c-up>
    map <f16> <c-down>
    map <f17> <c-pageup>
    map <f18> <c-pagedown>
    map! <f13> <c-left>
    map! <f14> <c-right>
    map! <f15> <c-up>
    map! <f16> <c-down>
    map! <f17> <c-pageup>
    map! <f18> <c-pagedown>

    " terminal title
    set t_ts=]2;
    set t_fs=
endif

if &term == "tmux-256color"
    " A subset of above that does not work in tmux. Note that ctrl-left/right works out-of-the-box and if above mappings
    " were used, it would not work correctly in vim's terminal emulator under tmux.
    set <f19>=[23;2~
    set <f20>=[24;2~
    nmap <f19> <S-F11>
    nmap <f20> <S-F12>

    set <f17>=[5;5~
    set <f18>=[6;5~
    map <f17> <c-pageup>
    map <f18> <c-pagedown>
    map! <f17> <c-pageup>
    map! <f18> <c-pagedown>
endif

" GNU screen: old versions (in fact any other than git master) don't support italics.
if &term == "screen.xterm-256color" || &term == "screen-256color" || &term == "screen-256color-fixed"
    " screen 4.99 supports italics, see: https://savannah.gnu.org/bugs/?36676
    " but unfortunately terminfo claims it doesn't:
    "ksachanowicz@ksachanowicz-dev:~$ infocmp xterm-256color screen.xterm-256color | grep "[sr]itm"
    "        ritm: '\E[23m', NULL.
    "        sitm: '\E[3m', NULL.
    " Let's fix it here. Sequence as output from 'tput sitm' under xterm-256color.
    set t_ZH=[3m
    set t_ZR=[23m
endif

if &term == "screen.xterm-256color"
    " On some systems SmartHome doesn't work without it.
    " Below is similar (but not exactly the same!) solution as https://vi.stackexchange.com/questions/12325/why-cant-i-set-home-or-t-kh-in-my-vimrc-file
    set <xHome>=[1~
    set <kHome>=[1~
    set <xEnd>=[4~
    set <kEnd>=[4~
endif

""""""""""""""""""""""""""""
" plugins

if v:version < 800

    call plug#begin()
    call plug#end()

    function! PlugLoaded(name)
        return 0
    endfunction

else

    call plug#begin()

    Plug 'preservim/nerdtree'
    Plug 'preservim/tagbar'
    if v:version >= 802
        Plug 'azabiong/vim-highlighter'
    endif

    Plug 'vim-ctrlspace/vim-ctrlspace'

    " obsoleted by LSP Semantic highlighting
    "Plug 'bfrg/vim-cpp-modern'

    Plug 'vim-airline/vim-airline'

    Plug 'tpope/vim-fugitive'
    " vim-unimpaired defines some useful mappings:
    " * [n and ]n to jump between SCM conflict markers
    " * ]q is :cnext. [q is :cprevious
    Plug 'tpope/vim-unimpaired'
    " Provides useful mappings:
    " zS: Show the active syntax highlighting groups under the cursor.
    Plug 'tpope/vim-scriptease'
    " Provides :Move (similar to :GMove from vim-fugitive), :Rename, :Delete, :Cfind, :Lfind
    Plug 'tpope/vim-eunuch'
    " This plugin automatically adjusts 'shiftwidth' and 'expandtab' heuristically based on the current file, or, in the
    " case the current file is new, blank, or otherwise insufficient, by looking at other files of the same type in the
    " current and parent directories.
    Plug 'tpope/vim-sleuth'

    if g:is_dev_host
        " Load LSP and autocompletion plugins.

        " asyncomplete.vim seems to provide slightly less relevant completions than YCM, especially for local variables - it
        " shows some global symbols first.
        " Also, function signature popup seems to work better in YCM.
        " vim-lsp seems to do some computations (maybe calls to language server) synchronously during typing. When coding
        " it causes Vim to freeze for about a second every few written words (even when writing a comment).
        let s:prefer_ycm = v:true
        if s:prefer_ycm
            Plug 'ycm-core/YouCompleteMe'
        else
            Plug 'prabirshrestha/vim-lsp'

            " Auto registration of LSP servers.
            " FIXME: vim-lsp-settings is commented out: clangd was started twice in a scenario when you start vim with only cpp
            " files (it's just one clangd) and you open a .c file (now there are 2 clangd instances running).
            "Plug 'mattn/vim-lsp-settings'

            Plug 'prabirshrestha/asyncomplete.vim'
            Plug 'prabirshrestha/asyncomplete-lsp.vim'
        endif
    endif

    " colorschemes
    Plug 'sainnhe/everforest'
    Plug 'sainnhe/edge'
    Plug 'joshdick/onedark.vim'
    Plug 'rhysd/vim-color-spring-night'
    " Disabled: only for neovim
    "Plug 'shaunsingh/nord.nvim'
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
    Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }
    Plug 'mcchrish/zenbones.nvim'
    Plug 'vim-scripts/systemrdl.vim'
    Plug 'Glench/Vim-Jinja2-Syntax'
    Plug 'mox-mox/vim-localsearch'
    Plug 'derekwyatt/vim-fswitch'

    " andymass/vim-matchup is a better version of matchit
    "packadd! matchit
    Plug 'andymass/vim-matchup'

    if v:version >= 901
        packadd! editorconfig
    endif

    Plug 'google/vim-maktaba'
    Plug 'bazelbuild/vim-bazel'

    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    Plug 'airblade/vim-gitgutter'

    Plug 'haya14busa/vim-asterisk'

    " vim-slash has a blink feature, vim-highlighter has it too, but only for jumps between highlights.
    "Plug 'junegunn/vim-slash'

    " This one has a blink feature for search and works with vim-asterisk:
    " FIXME: disabled for now, due to some issues:
    " - sometimes it pulses slowly (when jumping with gb)
    " - after 'n' it swallows ctrl-w if pressed immediately after, thus disturbing window switching
    " With vim 802 there are some errors with <f11> and <f12>
    if v:version >= 901
        Plug 'inside/vim-search-pulse'
    endif

    Plug 'junegunn/vim-easy-align'

    " FIXME: autocmd handler for CursorMoved that it adds is pretty slow - try h/l over a long line.
    Plug 'wellle/context.vim'

    Plug 'drzel/vim-line-no-indicator'
    Plug 'rhysd/conflict-marker.vim'

    "Plug 'jremmen/vim-ripgrep'

    if !has('nvim')
        Plug 'rhysd/vim-healthcheck'
    endif

    call plug#end()

    function! PlugLoaded(name)
        return (
            \ has_key(g:plugs, a:name) &&
            \ isdirectory(g:plugs[a:name].dir))
    endfunction

endif

""""""""""""""""""""""""""""
" useful functions

function! s:HighlightCurrentFunctionName()
    let l:tag_name = tagbar#currenttag('%s','','','scoped-stl')
    let l:tag_name = substitute(l:tag_name, '()', '', '')
    if l:tag_name == ''
        echo 'sorry, no function/tag here'
    else
        if l:tag_name =~ '^\~'
            " special case for C++ destructor
            let l:pattern = '\' . l:tag_name . '\>'
        else
            let l:pattern = '\<' . l:tag_name . '\>'
        endif
        " vim-highlighter adds '\m' to each pattern (meaning 'magic' which is vim default)
        if empty(HiList()->map({i,v -> v.pattern})->filter({i,v -> v ==# '\m' . l:pattern}))
            echo 'highlight current tag: ' . l:tag_name
            execute 'Hi + ' . l:pattern
        else
            echo 'unhighlight current tag: ' . l:tag_name
            execute 'Hi - ' . l:pattern
        endif
    endif
endfunction

function! s:HighlightPopulateLocationList()
    execute 'lvimgrep /\v('. HiList()->map({i,v -> v.pattern})->join('\v|'). '\v)/gj %'
endfunction

function! s:SmartHome()
    " this line checks if we are not on the first whitespace.
    if col('.') != match(getline('.'), '\S')+1
        norm ^
    else
        norm 0
    endif
endfunction

" FIXME: use :keepjumps
" Assumptions about C++ style:
" - { is at the first column on its own line
" - line before contains closing parens of a method parameter list
function! s:JumpPrevMethodCpp()
    " Jump to previous { in the first column, move line up and to the first column.
    " But first move line down: if user is already on { then we don't want [[ to jump to previous method.
    " This only addresses a case when user presses [[ first and then [m. If cursor is already in params list, user may
    " still want [m to jump to current method's name, but that's not handled.
    norm j[[k0
    call s:JumpToMethodNameCpp()
endfunction

" Assuming cursor is in a line with closing parens of C++ function/method parameter list, in the first column, jump to
" function's name.
function! s:JumpToMethodNameCpp()
    let l:line = getline('.')

    let l:comment_pos = stridx(l:line, '//')
    if l:comment_pos == -1
        let l:comment_pos = stridx(l:line, '/*')
        if l:comment_pos == -1
            let l:comment_pos = strlen(l:line)
        endif
    endif

    let l:close_parens_pos = strridx(l:line, ')', l:comment_pos)
    if l:close_parens_pos != -1
        call cursor(0, 1 + l:close_parens_pos)
        " jump to opening parens and move one word back
        norm %b
    endif
endfunction

function! s:JumpNextMethodCpp()
    " This one is more tricky: if we are on a method's name, then ]] will send us to opening bracket of current method,
    " not to the next one. We need to reverse last steps of JumpPrevMethodCpp: move to next word, see if it's an opening
    " parens and if so, jump to matching closing parens and move line down, which is supposed to be the line with
    " opening bracket. From there we need to call ]] once and move back to method's name, as in JumpPrevMethodCpp.
    " Actually, 'w' has this weird behavior that in this line:
    " ostream & operator <<(some args here)
    " If cursor is on '<' then 'w' jumps to function arguments, not to opening parens.
    norm 0
    let l:idx = stridx(getline('.'), '(')
    if l:idx != -1
        " opening parens is present, move to it
        if l:idx != 0
            norm f(
        endif
        " jump to closing parens
        norm %
    endif
    " Let's move to line below also if we didn't move to closing parens above. This is to ensure we move forward if we
    " are on such line:
    " struct VolumesComparator
    " In this case we move to line with '{' which is just after it.
    norm j
    " jump to next { in the first column, move line up and to the first column
    norm ]]k0
    call s:JumpToMethodNameCpp()
endfunction

""""""""""""""""""""""""""""
" key mappings

" Use Q for formatting in visual mode. In normal mode it should still switch to Ex mode.
vmap Q gq

nmap <silent> <C-N> :nohlsearch<CR>
nmap <silent> <C-K> :set invcursorline<CR>
nmap <C-j> :jumps<CR>

" ctrl-left/right should work the same in insert mode as in normal
imap <c-left> <c-\><c-o><c-left>
imap <c-right> <c-\><c-o><c-right>

" ctrl-up/down move cursor 1 row on screen (not necessarily in file)
map <c-up> g<up>
map <c-down> g<down>
imap <c-up> <c-\><c-o><c-up>
imap <c-down> <c-\><c-o><c-down>

" pageup/down keep cursor position
set nostartofline
imap <pageup> <c-\><c-o><c-u>
imap <pagedown> <c-\><c-o><c-d>
map <pageup> <c-u>
map <pagedown> <c-d>

" <home> jumps alternately to the first character of the line (column 1) or to
" the first non-blank character
inoremap <silent> <home> <C-O>:call <SID>SmartHome()<CR>
nnoremap <silent> <home> :call <SID>SmartHome()<CR>

" Built-in vim jump to next/previous methods work only in Java, not in C++. Even if you remove 'class X' at the
" beginning of a file, these work worse, for example [m jumps to a previous beginning or ending bracket. For C++ .cpp
" file they don't work at all, for example [m jumps to the beginning of enclosing namespace.
autocmd FileType c,cpp nmap <buffer> <silent> [m :call <SID>JumpPrevMethodCpp()<CR>
autocmd FileType c,cpp nmap <buffer> <silent> ]m :call <SID>JumpNextMethodCpp()<CR>

""""""""""""""""""""""""""""
" function key mappings

" Remove indenting on empty lines
nnoremap <silent> <F2> :%s/\s\+$//<CR>``

" Show control chars
nnoremap <silent> <F3> :set invlist<CR>

" Switch between C/C++ source and header file
if PlugLoaded('YouCompleteMe')
    nnoremap <silent> <F4> :YcmCompleter GoToAlternateFile<CR>
else
    " with vim-fswitch plugin
    nnoremap <silent> <F4> :FSHere<CR>
endif

set pastetoggle=<f5>

if PlugLoaded('nerdtree')
    inoremap <silent> <F6> <C-O>:NERDTreeToggle<CR>
    nnoremap <silent> <F6> :NERDTreeToggle<CR>

    inoremap <silent> <F7> <C-O>:NERDTreeFind<CR>
    nnoremap <silent> <F7> :NERDTreeFind<CR>
endif

if PlugLoaded('tagbar')
    "inoremap <silent> <F8> <C-O>:TagbarOpen fj<CR>
    nnoremap <silent> <F8> :TagbarOpen fj<CR>
endif

" :lopen seems to be pretty slow for large lists even if location list is already open!
" Therefore leaving it only for F10.
" Note: below is redefined for vim-search-pulse.
nnoremap <silent> <F10> :lopen \| ll<CR>
nnoremap <silent> <F11> :lprev<CR>
nnoremap <silent> <F12> :lnext<CR>
nnoremap <silent> <S-F11> :lpfile<CR>
nnoremap <silent> <S-F12> :lnfile<CR>

""""""""""""""""""""""""""""
" user commands

" :Bash
" force bash syntax if a file is wrongly recognized as plain sh
command! -nargs=0 -bar Bash let is_bash=1|set ft=sh

" :Title <title>
" change user part of terminal title
function! s:Title(string)
    "let &titlestring = a:string . ': %M %f (' . $USER . '@' . s:short_hostname . ')'
    "let &titlestring = a:string . ': %{fnamemodify(getcwd(), ":~")} (' . $USER . '@' . s:short_hostname . ')'
    let &titlestring = '[' . s:short_hostname . '] ' . a:string . ': %{fnamemodify(getcwd(), ":~")}'
endfunction

command! -nargs=1 Title call <SID>Title(<q-args>)

" This function can even be called directly from cmdline like:
" :call GenericGrepFun("vcsgrep", expand("<cword>"))
" with some custom grep-like script instead of "vcsgrep". However, it might make more sense to instead use standard grep
" command (which calls rg for me) and for some custom search pattern generation, do it like:
" :exe '!generate_search_patterns.sh % > _patterns.tmp' | lgrep -f _patterns.tmp
" to recursively search current directory for some patterns generated from current file.
function! GenericGrepFun(grep_cmd, grep_args)
    let l:old_grepprg = &grepprg
    let &grepprg = a:grep_cmd
    let l:old_grepformat = &grepformat
    let &grepformat = "%f:%l:%m,%f:%l%m,%f  %l%m"
    " 'execute' treats some characters specially, these are listed under fnameescape() but we want to pass quote char
    " directly to the shell, so we can't use fnameescape()
    execute "lgrep " . escape(a:grep_args, '|%#')
    let &grepprg = l:old_grepprg
    let &grepformat = l:old_grepformat
endfunction

" version-control-system aware grep, has -n implied
function! s:VcsgrepFun(grep_args)
    call GenericGrepFun("vcsgrep", a:grep_args)
endfunction

" in git repo typically this is faster
" UPDATE: but in Strike engine repo for some reason it became slow, use vcsgrep instead.
function! s:GitGrepFun(grep_args)
    call GenericGrepFun("git grep -n", a:grep_args)
endfunction

command! -nargs=1 Lvcsgrep call <SID>VcsgrepFun(<q-args>)
command! -nargs=1 Lgitgrep call <SID>GitGrepFun(<q-args>)

" Grep for word under cursor.
" @/ means '/' register which contains current search pattern
" Edit: replaced *`` with z* from vim-asterisk
nmap <silent> <leader>V z*:call <SID>VcsgrepFun(shellescape(@/))<CR>:lopen<CR>:lfirst<CR>
" FIXME: consider using a grep command from vim-fugitive plugin
nmap <silent> <leader>G z*:call <SID>GitGrepFun(shellescape(@/))<CR>:lopen<CR>:lfirst<CR>

nmap <leader>R :lgrep <c-r><c-w>

" FIXME: investigate why # in pattern breaks it - is it expanded to alt file name?
" Note: rg ignores files that are (incorrectly) in .gitignore but are actually tracked by git!
if executable("rg")
    set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
    set grepformat=%f:%l:%c:%m
elseif executable("vcsgrep")
    set grepprg=vcsgrep
endif

""""""""""""""""""""""""""""

" Match angle brackets in template C++ code
let g:matchup_matchpref = {'cpp': {'template': 1}}

" man pages displayed in vim (:Man)
runtime ftplugin/man.vim
" Display man pages in a vertical split by default.
let g:ft_man_open_mode = 'vert'
" Let 'K' display them in vim (<leader>K works always).
set keywordprg=:Man
" ftplugin sets it to ":Help" for bash, which doesn't show man in vim. Let's fix it:
autocmd FileType sh setlocal keywordprg=:Man
" Fix searching for \<fd\> in man page of mmap.
autocmd FileType man setlocal iskeyword-=.
autocmd FileType man setlocal iskeyword-=:

""""""""""""""""""""""""""""
" colorscheme settings

if has('termguicolors')
    " This 'if' is needed on Fedora 20, see also a workaround in .bashrc.
    if &term == "screen.xterm-256color" || &term == "xterm-256color" || &term == "screen-256color" || &term == "screen-256color-fixed" || &term == "tmux-256color"
        " Strangely, on Rocky9 these don't get set automatically:
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        " Note: for gnu screen it requires "truecolor on" in screenrc.
        set termguicolors
    endif
endif

function! s:CustomizeHighlightGeneric()
    "hi IncSearch      ctermfg=235 ctermbg=142 guifg=#272e33 guibg=#c2dc9a cterm=underline
    "hi Search         ctermfg=235 ctermbg=142 guifg=#272e33 guibg=#829a5c cterm=none
    hi link CurSearch IncSearch

    " WarningMsg is used for search wraparound. Make it bright.
    hi WarningMsg   cterm=none ctermfg=white ctermbg=red       gui=none guifg=white guibg=red

    " With vim-matchup, highlight of matching parenthesis can be confusing (it is kind of reverse of normal colors).
    " Especially with block cursor! Moreover, xml tags that are open-close (like <arg code="..." .. />) are highlighted
    " whole, which is distracting.
    " Edit: onedark has a reasonable setting.
    "hi clear MatchParen
    ""hi MatchParen term=underline cterm=underline gui=underline
    "" Alternatively let's link to Search.
    "hi link MatchParen Search

    " In some color schemes Todo has inverted colors (foreground same as Normal background), which makes text invisible
    " together with CursorLine (as it changes background to a similar color as Normal).
    hi clear Todo
    hi link Todo Keyword

    call s:CustomizeCppHighlight()
endfunction

function! s:CustomizeCppHighlight()
    hi link cppStructure Structure
    hi link cStructure cppStructure

    hi clear cStorageClass
    hi link cStorageClass StorageClass
    hi clear StorageClass
    hi link StorageClass Keyword

    " Structure normally links to Type.
    " Edit: not in onedark. Commented out below, because specSection links to Structure, and it caused rpm spec sections
    " be poorly visible.
    " YCM_HL_modifier is mapped to Keyword.
    "hi clear Structure
    "hi link Structure Keyword
    hi clear cppModifier
    hi link cppModifier Keyword
endfunction

"""""""" colorscheme: onedark """"""""

let g:onedark_terminal_italics = 1

function! s:CustomizeOnedark()
    call s:CustomizeHighlightGeneric()

    " C/C++ class/struct keywords should be blue instead of yellow, same as #include.
    " Edit: it looks like with semantic highlighting, YCM_HL_class uses Structure highlight group. This property is used
    " whenever a class is referenced, so for example in a parameter list.
    " These commands are useful to verify it:
    " echo prop_list(line('.'))
    " echo prop_type_get('YCM_HL_class')
    " class/struct keywords use cppStructure/cStructure highlight groups, respectively.
    "hi cppStructure ctermfg=39 guifg=#61AFEF

    " Make sure for/while/do/if/switch are not violet as constants (from #define).
    "hi clear Conditional
    "hi link Conditional Structure
    "hi clear Repeat
    "hi link Repeat Structure
    hi clear Macro
    hi link Macro Structure
    " cDefine normally links to Macro
    hi clear cDefine
    hi link cDefine Conditional

    " Swap these two.
    hi IncSearch term=reverse ctermfg=235 ctermbg=180 guifg=#282C34 guibg=#E5C07B
    hi Search term=reverse ctermfg=180 ctermbg=59 guifg=#E5C07B guibg=#5C6370

    " More contrast for comments. Taken from spring-night.
    " Note: by default it is:
    " Normal ctermfg=145 ctermbg=235 guifg=#ABB2BF guibg=#282C34
    hi Normal           ctermfg=231 ctermbg=233 guifg=#fffeeb guibg=#132132
    hi Comment          ctermfg=103 guifg=#8d9eb2
    hi clear SpecialComment
    hi link SpecialComment Comment
    hi clear gitcommitComment
    hi link gitcommitComment Comment
    hi clear gitCommitSummary
    hi link gitCommitSummary Normal
    " Tweak text color. spring-night has it too bright.
    hi Normal           ctermfg=145 guifg=#dfe0ee
    hi CursorLine       ctermbg=235 guibg=#1d2b3d

    " active tab page label
    hi TabLineSel term=bold ctermfg=145 ctermbg=235 guifg=#dfe0ee guibg=#3a4b5c
    " inactive tab page label
    hi TabLine term=underline ctermfg=103 ctermbg=235 guifg=#8d9eb2 guibg=#3a4b5c
    " tabline space with no labels
    hi TabLineFill term=reverse ctermbg=235 guibg=#3a4b5c

    hi StatusLine       cterm=bold ctermfg=231 ctermbg=238 gui=bold guifg=#fffeeb guibg=#536273
    hi StatusLineNC     ctermfg=103 ctermbg=235 guifg=#8d9eb2 guibg=#3a4b5c
    " same for terminal windows:
    hi clear StatusLineTerm
    hi clear StatusLineTermNC
    hi link StatusLineTerm StatusLine
    hi link StatusLineTermNC StatusLineNC

    " apply Normal to terminal windows:
    hi clear Terminal

    " make sure changed lines don't look like IncSearch
    hi clear DiffText
    hi clear DiffChange
    hi DiffText term=reverse cterm=reverse ctermfg=109 gui=reverse guifg=#7fbbb3
    hi DiffChange term=bold cterm=none ctermfg=180 gui=none guifg=#7fbbb3
endfunction

"""""""" colorscheme: edge """"""""

" Available values: 'default', 'aura', 'neon'
let g:edge_style = 'neon'
let g:edge_dim_foreground = 0
" For better performance
let g:edge_better_performance = 1

function! s:CustomizeEdge()
    call s:CustomizeHighlightGeneric()
endfunction

"""""""" colorscheme: everforest """"""""

" Set contrast.
" Available values: 'hard', 'medium'(default), 'soft'
let g:everforest_background = 'hard'
" For better performance
let g:everforest_better_performance = 1

function! s:CustomizeEverforest()
    call s:CustomizeHighlightGeneric()

    hi StatusLine   ctermfg=245 ctermbg=237 guifg=#d3c6aa guibg=#356824 cterm=none
    hi StatusLineNC ctermfg=245 ctermbg=236 guifg=#859289 guibg=#1a3610 cterm=none
    " same for terminal windows:
    hi clear StatusLineTerm
    hi clear StatusLineTermNC
    hi link StatusLineTerm StatusLine
    hi link StatusLineTermNC StatusLineNC

    hi CursorLine term=underline ctermbg=236 guibg=#252f33 cterm=none

    " original everforest (with g:everforest_background = 'hard')
    "hi Normal ctermfg=223 ctermbg=235 guifg=#d3c6aa guibg=#272e33
    hi Normal ctermfg=223 ctermbg=235 guifg=#d3c6aa guibg=#1d2328

    " apply Normal to terminal windows:
    "hi clear Terminal
endfunction

"""""""" colorscheme: spring-night """"""""

" don't use bold (somehow Identifier still has it in cterm)
let g:spring_night_kill_bold = 1
let g:spring_night_kill_italic = 1
" enable italic in cterm (e.g. for Identifier; otherwise it has cterm=bold)
"let g:spring_night_cterm_italic = 1

function! s:CustomizeSpringNight()
    call s:CustomizeHighlightGeneric()

    " Let's have types in blue, rather than yellow.
    hi clear Type
    hi link Type Statement

    " Don't use bold nor italic.
    hi Identifier cterm=none gui=none

    hi Keyword cterm=bold gui=bold

    hi CursorLine ctermbg=235 guibg=#1d2b3d

    " from evening colorscheme
    hi Terminal ctermfg=231 ctermbg=236 guifg=#ffffff guibg=#333333
endfunction

"""""""" colorscheme autocmds """"""""

autocmd ColorScheme onedark call <SID>CustomizeOnedark()
autocmd ColorScheme edge call <SID>CustomizeEdge()
autocmd ColorScheme everforest call <SID>CustomizeEverforest()
autocmd ColorScheme spring-night call <SID>CustomizeSpringNight()

""""""""""""""""""""""""""""
" vim-ctrlspace configuration

"let g:CtrlSpaceDefaultMappingKey = "<leader>s"

"let g:CtrlSpaceLoadLastWorkspaceOnStart = 1
let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
let g:CtrlSpaceSaveWorkspaceOnExit = 1

" mappings
if PlugLoaded('vim-ctrlspace')
    " Fuzzy search files with Ctrl-P
    " Commented out, fzf.vim does it better.
    "nmap <silent> <C-p> :CtrlSpace O<CR>
endif

""""""""""""""""""""""""""""
" LSP common configuration - things that should be shared between vim-lsp and YouCompleteMe.

let s:clangd_common_args = [
    \ '--header-insertion=never'
\ ]

" https://github.com/ycm-core/YouCompleteMe/wiki/FAQ#im-using-clangd-and-it-is-inserting-headers-that-i-dont-want
" For query-driver see https://clangd.llvm.org/design/compile-commands
" https://github.com/hedronvision/bazel-compile-commands-extractor even suggests to use: --query-driver=**
"
" You should see something like this in clangd logs:
"
" > I[15:01:37.301] System includes extractor: successfully executed /opt/icecream/bin/g++-8
"
" Note that cmake may use /usr/bin/c++ (not g++) so we must use wildcard.
" Watch out: Ubuntu 22.04 and Mint 21 are affected by an issue that system includes extractor does not work for headers
" of boost. Workaround: sudo apt install g++-12
" See https://github.com/clangd/clangd/issues/1394#issuecomment-1328676884
call add(s:clangd_common_args, '--query-driver=/usr/bin/*')
call add(s:clangd_common_args, '--query-driver=/opt/icecream/bin/*')
" For debugging:
"call add(s:clangd_common_args, '--log=verbose')

""""""""""""""""""""""""""""
" LSP mappings

if PlugLoaded('YouCompleteMe')
    " GoTo symbol
    if PlugLoaded('vim-search-pulse')
        nnoremap gb :YcmCompleter GoTo<CR><Plug>Pulse
    else
        nnoremap gb :YcmCompleter GoTo<CR>
    endif

    " Hover (aka Documentation)
    nmap <leader>D <Plug>(YCMHover)

    " Search for symbols
    nmap <leader>sw <Plug>(YCMFindSymbolInWorkspace)
    nmap <leader>sd <Plug>(YCMFindSymbolInDocument)

    nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
    nnoremap <leader>gi :YcmCompleter GoToImplementation<CR>
    nnoremap <leader>gt :YcmCompleter GoToType<CR>
    nnoremap <leader>gs :YcmCompleter GoToSymbol <c-r><c-w>

    nnoremap <leader>rn :YcmCompleter RefactorRename<space>
endif

" vim-lsp
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes

    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    " GoTo symbol
    " For some reason <Plug>Pulse doesn't work here.
    nmap <buffer> gb <Plug>(lsp-definition)

    " Hover (aka Documentation)
    nmap <buffer> <leader>D <Plug>(lsp-hover)

    " Search for symbols
    nmap <buffer> <leader>sw <Plug>(lsp-workspace-symbol-search)
    nmap <buffer> <leader>sd <Plug>(lsp-document-symbol-search)

    nmap <buffer> <leader>gr <Plug>(lsp-references)
    nmap <buffer> <leader>gi <Plug>(lsp-implementation)
    nmap <buffer> <leader>gt <Plug>(lsp-type-definition)

    nmap <buffer> <leader>rn <Plug>(lsp-rename)

    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)

    " Scroll popup window
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-b> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

if PlugLoaded('asyncomplete.vim')
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr>    pumvisible() ? "\<C-y>"  : "\<cr>"

    let g:asyncomplete_auto_popup = 1

    if g:asyncomplete_auto_popup
        inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    else
        function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
        endfunction

        inoremap <silent><expr> <Tab>
                    \ pumvisible() ? "\<C-n>" :
                    \ <SID>check_back_space() ? "\<Tab>" :
                    \ asyncomplete#force_refresh()
    endif

elseif PlugLoaded('YouCompleteMe')
    " these are defaults:
    "let g:ycm_key_list_select_completion = ['<Tab>', '<Down>']
    "let g:ycm_key_list_previous_completion = ['<S-Tab>', '<Up>']
    "let g:ycm_key_list_stop_completion = ['<C-y>']

    let g:ycm_key_list_stop_completion = ['<cr>']
endif

""""""""""""""""""""""""""""
" vim-lsp specific configuration

if PlugLoaded('vim-lsp')
    "let g:lsp_log_verbose = 1
    "let g:lsp_log_file = expand('~/vim-lsp.log')

    let g:lsp_semantic_enabled = 1

    " Make virtual text diagnostics less distracting.
    hi link LspWarningVirtualText Comment

    let s:clangd_command = [
            \ exepath("clangd")
        \ ]

    if PlugLoaded('vim-lsp-settings')
        let g:lsp_settings = {
            \ 'clangd': {
                \ 'cmd': s:clangd_command + s:clangd_common_args
            \ },
            \ 'efm-langserver': {'disabled': v:true}
        \}
    else
        " Register LSP servers manually.
        if executable(s:clangd_command[0])
            au User lsp_setup call lsp#register_server({
                \ 'name': 'clangd',
                \ 'cmd': s:clangd_command + s:clangd_common_args,
                \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp', 'cuda'],
                \ })
        endif

        if executable('pylsp')
            " pip install python-lsp-server
            au User lsp_setup call lsp#register_server({
                \ 'name': 'pylsp',
                \ 'cmd': {server_info->['pylsp']},
                \ 'allowlist': ['python'],
                \ })
        endif
    endif
endif

""""""""""""""""""""""""""""
" YouCompleteMe specific configuration
" Note: Some options need to go to ~/.vim/after/plugin/additional_settings.vim

if PlugLoaded('YouCompleteMe')
    let g:ycm_clangd_binary_path = exepath("clangd")

    let g:ycm_clangd_args = s:clangd_common_args

    let g:ycm_log_level = 'info'

    " Let clangd fully control code completion
    " Edit: is it really needed? Sometimes there is a weird error about "document modified" with it.
    " Edit2: uncommenting, as I'm getting ID-only completions, rather than semantic
    let g:ycm_clangd_uses_ycmd_caching = 0

    " Disable auto hover
    let g:ycm_auto_hover = ''

    " This is the default:
    "let g:ycm_key_detailed_diagnostics = '<leader>d'
    " Less intrusive diagnostics:
    let g:ycm_warning_symbol = '>'
    " diagnostics highlighting unfortunately overrides normal syntax highlighting, so let's disable it:
    let g:ycm_enable_diagnostic_highlighting = 0
    " Semantic highlighting based on LSP
    let g:ycm_enable_semantic_highlighting = 1

    let g:ycm_global_ycm_extra_conf = '~/ycm_global_extra_conf.py'

    " Clangd 17.0.1 added new semantic highlight groups which are not defined in YCM.
    call prop_type_add( 'YCM_HL_label', { 'highlight': 'Normal' } )

    " These are normally mapped to Structure and Structure links to Type.
    " Edit: in everforest, YCM_HL_class maps to TSType.
    " We don't want them to map to Structure because it's also used in classic syntax highlighting for keywords like
    " class/struct. Instead, map to Type directly and change Structure highlight group (in CustomizeCppHighlight).
    call prop_type_add( 'YCM_HL_class', { 'highlight': 'Type' } )
    call prop_type_add( 'YCM_HL_enum', { 'highlight': 'Type' } )
endif

function! RunClangFormat()
    let l:formatdiff = 1
    let l:clang_format_py_path = fnamemodify(exepath("clang-format"), ":h:h") . "/share/clang/clang-format.py"
    " Assuming CWD is repo root, prevent running clang-format in projects without a config file, which likely don't use
    " clang-format at all.
    if filereadable(".clang-format")
        call execute("py3f " . l:clang_format_py_path)
    endif
endfunction
if executable("clang-format") && has("python3")
    autocmd BufWritePre *.h,*.c,*.hpp,*.cc,*.cpp call RunClangFormat()
endif

""""""""""""""""""""""""""""
" choose a colorscheme

" Note: this must be after prop_type_add() calls
colorscheme onedark
"colorscheme edge
"colorscheme everforest
"colorscheme spring-night

""""""""""""""""""""""""""""
" vim-asterisk configuration

if PlugLoaded('vim-asterisk')
    map *   <Plug>(asterisk-*)
    map #   <Plug>(asterisk-#)
    map g*  <Plug>(asterisk-g*)
    map g#  <Plug>(asterisk-g#)
    map z*  <Plug>(asterisk-z*)
    map gz* <Plug>(asterisk-gz*)
    map z#  <Plug>(asterisk-z#)
    map gz# <Plug>(asterisk-gz#)
endif

" Note: fugitive has its own * mapping:
"                           *fugitive_star*
" * On the first column of a + or - diff line, search for
"   the corresponding - or + line.  Otherwise, defer to
"   built-in |star|.
"
"                           *fugitive_#*
" # Same as "*", but search backward.

""""""""""""""""""""""""""""
" inside/vim-search-pulse configuration

" Default is 'cursor_line'
"let g:vim_search_pulse_mode = 'pattern'

let g:vim_search_pulse_disable_auto_mappings = 1
let g:vim_search_pulse_duration = 100

if PlugLoaded('vim-search-pulse')
    if PlugLoaded('vim-asterisk')
        map *   <Plug>(asterisk-*)<Plug>Pulse
        map #   <Plug>(asterisk-#)<Plug>Pulse
        map g*  <Plug>(asterisk-g*)<Plug>Pulse
        map g#  <Plug>(asterisk-g#)<Plug>Pulse
        map z*  <Plug>(asterisk-z*)<Plug>Pulse
        map gz* <Plug>(asterisk-gz*)<Plug>Pulse
        map z#  <Plug>(asterisk-z#)<Plug>Pulse
        map gz# <Plug>(asterisk-gz#)<Plug>Pulse
    endif

    " Observations:
    " - pulse is only on the first occurrence in a given line (after jump, so if backwards, it's on the last in a line)
    " - if a pattern is for example 'grep' then on most lines it works fine, and there are some lines where it flashes
    "   weirdly
    nmap n n<Plug>Pulse
    nmap N N<Plug>Pulse
    " Pulses cursor line on first match
    " when doing search with / or ?
    cmap <silent> <expr> <enter> search_pulse#PulseFirst()

    nnoremap <silent> <F10> :lopen \| ll<CR><Plug>Pulse
    nnoremap <silent> <F11> :lprev<CR><Plug>Pulse
    nnoremap <silent> <F12> :lnext<CR><Plug>Pulse
    nnoremap <silent> <S-F11> :lpfile<CR><Plug>Pulse
    nnoremap <silent> <S-F12> :lnfile<CR><Plug>Pulse
endif

""""""""""""""""""""""""""""
" vim-easy-align configuration

" Start interactive EasyAlign in visual mode (e.g. vipgA)
xmap gA <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gAip)
nmap gA <Plug>(EasyAlign)

""""""""""""""""""""""""""""
" context.vim configuration

" extracted from ~/.vim/plugged/context.vim/autoload/context/settings.vim and improved to also ignore C goto labels
" (typical in kernel code)
"let g:context_skip_regex = '^\([<=>]\{7\}\|\s*\($\|#\|//\|/\*\|\*\($\|\s\|/\)\)\)'
let g:context_skip_regex = '^\([<=>]\{7\}\|\s*\($\|#\|//\|/\*\|\*\($\|\s\|/\)\|\k\+:$\)\)'

""""""""""""""""""""""""""""
" rhysd/conflict-marker.vim configuration

" vim-unimpaired defines them as '[n' and ']n'; those with 'x' are to encode and decode XML (and HTML)
let g:conflict_marker_enable_mappings = 0

"nmap <leader>]x <Plug>(conflict-marker-next-hunk)
"nmap <leader>[x <Plug>(conflict-marker-prev-hunk)
nmap <leader>ct <Plug>(conflict-marker-themselves)
nmap <leader>co <Plug>(conflict-marker-ourselves)
nmap <leader>cn <Plug>(conflict-marker-none)
nmap <leader>cb <Plug>(conflict-marker-both)
nmap <leader>cB <Plug>(conflict-marker-both-rev)

""""""""""""""""""""""""""""
" airline configuration

if PlugLoaded('vim-airline')
    " disable '-- INSERT --' in the last line
    set noshowmode

    let g:airline#extensions#branch#displayed_head_limit = 45
    " to truncate all path sections but the last one, e.g. a branch
    " 'foo/bar/baz' becomes 'f/b/baz', use
    let g:airline#extensions#branch#format = 2

    let g:airline#extensions#tagbar#flags = 'f'
    let g:airline#extensions#tagbar#searchmethod = 'scoped-stl'

    let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

    " certain number of spaces are allowed after tabs, but not in between
    " this algorithm works well for /* */ style comments in a tab-indented file
    " Commented out for ostTesting.
    "let g:airline#extensions#whitespace#mixed_indent_algo = 1
    " Let's disable. One can always enable it with :AirlineToggleWhitespace.
    let g:airline#extensions#whitespace#enabled = 0

    "let g:airline_left_sep = '»'
    "let g:airline_left_sep = '▶'
    "let g:airline_right_sep = '«'
    "let g:airline_right_sep = '◀'
    let g:airline_powerline_fonts = 1

    " This is set automatically by vim-airline, but it doesn't work that way - vim-ctrlspace ignores it.
    " We must set it in vimrc.
    let g:CtrlSpaceStatuslineFunction = "airline#extensions#ctrlspace#statusline()"

    " Note: don't try to modify highlight groups (like airline_x), they're controlled by airline theme and any changes are
    " overwritten. Probably AirlineThemePatch could be used for that, but I didn't test it.
    function! AirlineInitSections()
        " Better ruler, see statusline setting in ~/.vim/after/plugin/additional_settings.vim
        " Airline doesn't reserve enough space for line/column numbers.
        "let g:airline_section_z = '%4l:%3v  %P'
        " Using vim-line-no-indicator:
        let g:airline_section_z = '%3v %P%{LineNoIndicator()}'

        call airline#parts#define_accent('tagbar', 'bold')
        " HACK: accent is not applied if section isn't created afterwards. I copied below line from
        " ~/.vim/plugged/vim-airline/autoload/airline/init.vim
        let g:airline_section_x = airline#section#create_right(['coc_current_function', 'bookmark', 'scrollbar', 'tagbar', 'taglist', 'vista', 'gutentags', 'gen_tags', 'omnisharp', 'grepper', 'filetype'])
    endfunction
    autocmd User AirlineAfterInit call AirlineInitSections()

elseif PlugLoaded('tagbar')
    " vim-airline not loaded but we have tagbar

    " tagbar#currenttag() caches some information and it works well only when used in a context of current (active) window
    " therefore this is commented out:
    "set statusline=%<%f%h%m%r\ %{tagbar#currenttag('\ %s','','f','scoped-stl')}\ %=%-14.(%l,%c%V%)\ %P
    function! PrepareStatusLine()
        if g:statusline_winid == win_getid()
            " this is current (active) window, use tagbar
            return "%<%f%h%m%r  %{tagbar#currenttag('%s','','f','scoped-stl')}%=%-14.(%l,%c%V%) %P"
        endif
        return "%<%f%h%m%r%=%-14.(%l,%c%V%) %P"
    endfunction
    set statusline=%!PrepareStatusLine()
endif

""""""""""""""""""""""""""""
" vim-line-no-indicator configuration

" one char wide solid vertical bar
let g:line_no_indicator_chars = [
    \  ' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'
    \  ]

"" two char wide fade-in blocks
"let g:line_no_indicator_chars = [
"  \ '  ', '░ ', '▒ ', '▓ ', '█ ', '█░', '█▒', '█▓', '██'
"  \ ]
"
"" three char wide solid horizontal bar
"let g:line_no_indicator_chars = [
"  \ '   ', '▏  ', '▎  ', '▍  ', '▌  ',
"  \ '▋  ', '▊  ', '▉  ', '█  ', '█▏ ',
"  \ '█▎ ', '█▍ ', '█▌ ', '█▋ ', '█▊ ',
"  \ '█▉ ', '██ ', '██▏', '██▎', '██▍',
"  \ '██▌', '██▋', '██▊', '██▉', '███'
"  \ ]

""""""""""""""""""""""""""""
" vim-highlighter configuration

" By default it is 't<CR>' which clashes with 't' (open in new tab) in some plugins.
let HiSetSL = '\f<CR>'

if PlugLoaded('vim-highlighter')
    " Vim Highlighter
    " <Leader> is by default mapped to \
    nnoremap <Leader>]  <Cmd>Hi><CR>
    nnoremap <Leader>[  <Cmd>Hi<<CR>
    nnoremap <Leader>}  <Cmd>Hi}<CR>
    nnoremap <Leader>{  <Cmd>Hi{<CR>

    command! -nargs=0 -bar HiListAll call <SID>HighlightPopulateLocationList()|lopen

    if PlugLoaded('tagbar')
        nnoremap <silent> <C-H> :call <SID>HighlightCurrentFunctionName()<CR>
    endif
endif

""""""""""""""""""""""""""""
" vim-localsearch configuration
nmap <leader>/ <Plug>localsearch_toggle

" Key mappings are in ~/.vim/after/plugin/additional_settings.vim

""""""""""""""""""""""""""""
" fzf.vim configuration
"let g:fzf_command_prefix = 'Fzf'

function! s:AddCwordAsQuery(fzf_args)
    let a:fzf_args['options'] = ['--query', expand('<cword>')]
    return a:fzf_args
endfunction

" mappings
if PlugLoaded('fzf.vim')
    "nnoremap <leader>fl :Lines<CR>
    "nnoremap <leader>fbl :BLines<CR>
    "nnoremap <leader>ft :Tags<CR>
    "nnoremap <leader>fbt :BTags<CR>

    " Search for files in git repo:
    nmap <C-p> :GFiles<CR>
    " As above but it starts finder with a word under cursor.
    nmap <silent> <leader>F :call fzf#vim#gitfiles('', fzf#vim#with_preview(<SID>AddCwordAsQuery({})), 0)<CR>
    " Same but for :Tags.
    nmap <silent> <leader>T :call fzf#vim#tags('', fzf#vim#with_preview(<SID>AddCwordAsQuery({ "placeholder": "--tag {2}:{-1}:{3..}" })), 0)<CR>
endif

""""""""""""""""""""""""""""
" gitgutter configuration
let g:gitgutter_use_location_list = 1

""""""""""""""""""""""""""""
" settings which must be at the end

" include program name in default title, to quickly see console tabs with vim
" called as 'view' (read-only mode)
call <SID>Title(v:progname)
set modeline
