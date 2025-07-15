# color ls
alias ls='ls --color=auto'
# not sure why it's not default for diff
# "always" so that it's colored even when piped to diff-highlight
# UPDATE: it's not default because sometimes we might want to save a diff to a file!
#alias diff='diff --color=always'
alias diff-color='diff --color=always'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# color grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# color zgrep
alias zgrep='zgrep --color=auto'
alias zfgrep='zfgrep --color=auto'
alias zegrep='zegrep --color=auto'

# Set terminal title for long running commands.
alias sleep="terminal_title_wrapper sleep"
alias man="terminal_title_wrapper man"
alias vcsgrep="terminal_title_wrapper vcsgrep"
alias make="terminal_title_wrapper make"

#alias git="terminal_title_wrapper git"

# do not connect to X server
alias vim="vim -X"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
