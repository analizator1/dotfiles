" KS: plugins are loaded after .vimrc, so exists() needs to be called from after/plugin/.
" EDIT: moved most entries back to .vimrc and calls to exists() replaced with PlugLoaded().

if exists('g:loaded_youcompleteme')
    " Disable YCM in vim-fugitive buffers
    let g:ycm_filetype_blacklist['git'] = 1
    " And also in man buffers, when run from shell and MANPAGER is set to run vim.
    " Something breaks in "~/.vim/plugged/YouCompleteMe/third_party/ycmd/ycmd/utils.py", line 187, in GetUnusedLocalhostPort.
    "let g:ycm_filetype_blacklist['man'] = 1
endif
