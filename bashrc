# vim:sw=4:expandtab:tw=120
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# terminal_title_wrapper with 'man' checks screen size from env so make sure it is exported
export LINES COLUMNS

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Don't use UTF-8 due to GNU grep 2.6.3 being very slow with -i flag:
# https://stackoverflow.com/questions/13819635/why-is-grep-ignore-case-50-times-slower
if [[ $(grep --version) == "GNU grep 2.6.3"* ]]; then
    # FIXME: we shouldn't revert to non-UTF-8 locale, as some vim plugins require it, for example ~/.vim/plugged/context.vim/README.md
    echo ".bashrc: warning: this version of GNU grep has slow -i, when used with UTF-8 locale"
    #echo ".bashrc: GNU grep has slow -i, using non-UTF-8 locale"
    #export LANG="en_US"
    #export LANGUAGE="en_US"
    #export LC_ALL="en_US"
    #export LC_TIME="en_US"
else
    export LANG="en_US.UTF-8"
    export LANGUAGE="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    export LC_TIME="en_US.UTF-8"
fi

__set_term()
{
    echo ".bashrc: setting TERM=$1"
    TERM=$1
}

color_prompt=
if [[ $(uname -s) == "AIX" ]]; then
    color_prompt=yes
elif [[ -x /usr/bin/tput ]]; then
    if tput setaf 1 &>/dev/null; then
        color_prompt=yes
    else
        echo ".bashrc: warning: setaf terminal capability not available with TERM=$TERM"
        # Fedora 20/RH6 don't have necessary terminfo entry, try some workarounds.
        # For screen.xterm-256color-nc57 see ~/.terminfo/README-KS.txt
        if [[ $TERM == "screen.xterm-256color" || $TERM == "tmux-256color" ]]; then
            if TERM="screen-256color-fixed" tput setaf 1 &>/dev/null; then
                color_prompt=yes
                __set_term "screen-256color-fixed"
            elif TERM="screen.xterm-256color-nc57" tput setaf 1 &>/dev/null; then
                color_prompt=yes
                __set_term "screen.xterm-256color-nc57"
            elif TERM="screen-256color" tput setaf 1 &>/dev/null; then
                color_prompt=yes
                __set_term "screen-256color"
            elif TERM="xterm-256color" tput setaf 1 &>/dev/null; then
                color_prompt=yes
                __set_term "xterm-256color"
            fi
        fi
    fi
fi

MANPATH="/usr/local/share/man:$MANPATH"
LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/sachanowicz/scripts" ] ; then
    PATH="$HOME/sachanowicz/scripts:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/clangd/19.1.0/llvm_install/bin" ] ; then
    PATH="$HOME/clangd/19.1.0/llvm_install/bin:$PATH"
fi

# Install go for more modern tools, like:
# * https://github.com/tigrawap/slit   A good 'less' replacement. Works much faster for complex regexes.
#   For some reason 'less' is very slow (but grep -E is fast).
if [ -d "/usr/local/go/bin" ] ; then
    PATH="/usr/local/go/bin:$PATH"
fi

# 'go' packages are here:
if [ -d "$HOME/go/bin" ] ; then
    PATH="$HOME/go/bin:$PATH"
fi

export PATH LD_LIBRARY_PATH MANPATH PKG_CONFIG_PATH

print_cluster_name()
{
    return 0
}

if [[ -f ~/.location_tag ]]; then
    custom_bashrc=~/.bashrc_$(< ~/.location_tag)
    if [[ -f $custom_bashrc ]]; then
        . $custom_bashrc
    else
        echo "custom_bashrc: '$custom_bashrc' does not exist!" >&2
    fi
    unset custom_bashrc
fi

if [ "$color_prompt" = yes ]; then
    COLOR_NONE="\e[0m"    # unsets color to term's fg color

    # FIXME: colors should probably be set using 'tput setaf <color_idx>'
    # regular colors
    COLOR_K="\e[0;30m"    # black
    COLOR_R="\e[0;31m"    # red
    COLOR_G="\e[0;32m"    # green
    COLOR_Y="\e[0;33m"    # yellow
    COLOR_B="\e[0;34m"    # blue
    COLOR_M="\e[0;35m"    # magenta
    COLOR_C="\e[0;36m"    # cyan
    COLOR_W="\e[0;37m"    # white

    # emphasized (bolded) colors
    COLOR_EMK="\e[1;30m"
    COLOR_EMR="\e[1;31m"
    COLOR_EMG="\e[1;32m"
    COLOR_EMY="\e[1;33m"
    COLOR_EMB="\e[1;34m"
    COLOR_EMM="\e[1;35m"
    COLOR_EMC="\e[1;36m"
    COLOR_EMW="\e[1;37m"

    # background colors
    COLOR_BGK="\e[40m"
    COLOR_BGR="\e[41m"
    COLOR_BGG="\e[42m"
    COLOR_BGY="\e[43m"
    COLOR_BGB="\e[44m"
    COLOR_BGM="\e[45m"
    COLOR_BGC="\e[46m"
    COLOR_BGW="\e[47m"
fi

fancy_trunc_string()
{
    local string=$1 maxlen=$2
    if (( ${#string} > maxlen )); then
        echo "..${string: -$maxlen}"
    else
        echo "$string"
    fi
}

ps1_print_workdir_without_color()
{
    local short_pwd=$1
    fancy_trunc_string "$short_pwd" $((50 * COLUMNS / 230)) || echo '!error!'
}

ps1_print_git_info()
{
    if type __git_ps1 &>/dev/null; then
        local text=$(__git_ps1 "(%s)" 2>/dev/null || echo '!error!')
        fancy_trunc_string "$text" $((50 * COLUMNS / 230)) || echo '!error!'
    fi
}

set_ps1()
{
    case "$TERM" in
    xterm*|rxvt*|dtterm|screen*|tmux*)
        # To see this title in a window environment, it must be configured. For KDE Konsole, change profile: in "Tabs" configuration
        # format must be set as '%w' (title set by shell).
        # No matter if running under screen, append SCREEN_TITLE.
        local TERMINAL_TITLEBAR="\[\e]0;[\h] \$(ps1_print_workdir_without_color \"\w\") | \$SCREEN_TITLE\a\]"
        ;;
    *)
        ;;
    esac
    case "$TERM" in
    screen*)
        # We're under GNU screen, use escape sequence to set window title inside screen.
        # Note for 4 backslashes: "\\" (inside a bash string) collapses to one backslash, so 2 are left. Then these 2
        # are interpreted by PS1. From bash manual:
        # \e     an ASCII escape character (033)
        # \\     a backslash
        # \[     begin a sequence of non-printing characters, which could be used to embed a terminal control sequence into  the
        #        prompt
        # \]     end a sequence of non-printing characters
        local GNU_SCREEN_TITLEBAR="\[\ek\u@\h | \$(ps1_print_workdir_without_color \"\w\") | \$SCREEN_TITLE\e\\\\\]"
        ;;
    *)
        ;;
    esac

    # Note: assigning colors here makes sense only for things that don't change throughout a bash session. If something
    # changes (like PWD) then a command to produce it should be added to PS1 inside a "\$(command here)" so that it is
    # evaluated on each prompt.
    local COLOR_OF_HOST=$COLOR_W
    if [[ -n $color_of_host_var ]]; then
        COLOR_OF_HOST=${!color_of_host_var}
        unset color_of_host_var
    fi

    case "$USER" in
        root)
            local COLOR_OF_USER=$COLOR_R ;;
        *)
            local COLOR_OF_USER=$COLOR_M ;;
    esac

    local COLOR_OF_WORKDIR=$COLOR_EMB

    local COLOR_OF_CMDLINE=$COLOR_NONE
    # bash older than 4.4 does not have PS0
    if (( ${BASH_VERSINFO[0]} >= 5 || ( ${BASH_VERSINFO[0]} == 4 && ${BASH_VERSINFO[1]} >= 4 ) )); then
        local COLOR_OF_CMDLINE=$COLOR_C
    fi

    PROMPT_COMMAND="PS1_RET=\$?"
    PS1="${TERMINAL_TITLEBAR}\$([[ \$PS1_RET -ne 0 ]] && echo \"\[${COLOR_EMR}\](ret: \$PS1_RET)\")\
\$([[ \j -ne 0 ]] && echo \"\[${COLOR_B}\](jobs: \j)\")\
\[${COLOR_OF_USER}\]\u@\[${COLOR_OF_HOST}\]\$(print_cluster_name)\h\[${COLOR_NONE}\]:\
\[${COLOR_OF_WORKDIR}\]\$(ps1_print_workdir_without_color \"\w\")\
\[${COLOR_EMG}\]\$(ps1_print_git_info)\[${COLOR_NONE}\]\
${GNU_SCREEN_TITLEBAR}\\\$ \[${COLOR_OF_CMDLINE}\]"

    # cancel COLOR_OF_CMDLINE before executing a command
    PS0="\[${COLOR_NONE}\]"
}

set_ps1
unset set_ps1

# print useful info on login
echo -e "${COLOR_R}===== [BASH] $(date) =====${COLOR_NONE}"

SCREEN_TITLE="(untitled)"
set_screen_title()
{
    SCREEN_TITLE=$1
}

if [[ $TERM != screen* ]]; then
    # After logging to remote host it's good to know if there is a screen to attach to (or already attached one).
    if which screen &>/dev/null; then
        screen -ls
    fi
fi

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# In case bash_completion is not present:
if ! type __git_ps1 &>/dev/null; then
    if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
        . /usr/share/git-core/contrib/completion/git-prompt.sh
    fi
fi

#export CXXFLAGS="-Wall -O2 -Wextra -Wvla -Winit-self -Wnon-virtual-dtor -Woverloaded-virtual"
#export CFLAGS="-Wall -O2 -Wextra -Wvla -Winit-self"
unset CFLAGS CXXFLAGS

export CMAKE_EXPORT_COMPILE_COMMANDS=1

# Note this option:
#   -X or --no-init
# makes 'less' leave its contents on screen after it exits. This is often unwanted, as it wastes terminal scroll buffer,
# and some older terminal history may go away.
export LESS="-RS"
export SYSTEMD_LESS="RS"

if command -v vim >/dev/null; then
    export MANPAGER="vim +MANPAGER --not-a-term -"
    export EDITOR=vim
fi

# There are systems which disable this:
stty susp ^z

if [ -f ~/.bashrc_gitconfig ]; then
    . ~/.bashrc_gitconfig
fi

# fix for eclipse under xpra
# It's no longer needed. In fact, necessary environment variables are set in a program started by xpra itself, such as
# when using "xpra start --start=xterm", then xterm has proper env vars.
#export GTK_IM_MODULE=ibus
# For the reason described above, not all programs work properly when started from ssh session with only DISPLAY set.
# One example is xreader, which has a delay of a few seconds when started from a bare ssh terminal.
# Nevertheless, below allows to run programs under xpra, by using just ssh session.
# First check for xpra sessions, then x2go. Reason: Chrome renders slowly under x2go.
# Ignore existing DISPLAY (unless it is :0 which means desktop X session), which may be orphaned, as GNU screen keeps
# env vars from when it was started and each new window is opened with old env even if env is different at the point of
# re-attach.
if [[ $DISPLAY != ":0" ]]; then
    if [[ -n $(pgrep xpra) ]]; then
        XPRA_LIST_OUT=$(xpra list-sessions 2>/dev/null)
        ret=$?
        if [[ $ret -ne 0 ]]; then
            echo "Error listing xpra sessions" >&2
        else
            session_ids=( $(echo "$XPRA_LIST_OUT" | sed -n 's/\bSocketState.LIVE.*//p') )
            if [[ ${#session_ids[@]} -eq 1 ]]; then
                id_to_use=${session_ids[0]}
                if [[ $id_to_use != $DISPLAY ]]; then
                    echo ".bashrc: setting DISPLAY for xpra: $id_to_use"
                    export DISPLAY=$id_to_use
                fi
            elif [[ ${#session_ids[@]} -gt 1 ]]; then
                echo ".bashrc: don't know which xpra session to use. Sessions:" "${#session_ids[@]}"
            fi
        fi
    elif which x2golistsessions &>/dev/null; then
        session_ids=( $(x2golistsessions | cut -d'|' -f3) )
        if [[ ${#session_ids[@]} -eq 1 ]]; then
            id_to_use=":${session_ids[0]}"
            if [[ $id_to_use != $DISPLAY ]]; then
                echo ".bashrc: setting DISPLAY for x2go: $id_to_use"
                export DISPLAY=$id_to_use
            fi
        fi
    fi
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/sachanowicz/google-cloud-sdk/path.bash.inc' ]; then . '/home/sachanowicz/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/sachanowicz/google-cloud-sdk/completion.bash.inc' ]; then . '/home/sachanowicz/google-cloud-sdk/completion.bash.inc'; fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Keep aliases last, because for example ~/.bashrc_gitconfig invokes some commands that are aliased with
# terminal_title_wrapper and we don't need aliases to interfere with it.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
