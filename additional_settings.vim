" KS: plugins are loaded after .vimrc, so exists() needs to be called from after/plugin/.
" EDIT: moved most entries back to .vimrc and calls to exists() replaced with PlugLoaded().

if exists('g:loaded_youcompleteme')
    " Disable YCM in vim-fugitive buffers
    let g:ycm_filetype_blacklist['git'] = 1
endif
