#
# local preferences
#
[ -e $HOME/.zsh-local/prefs ] && . $HOME/.zsh-local/prefs


#
# prompt settings
#
autoload -Uz vcs_info
zshvcsprompt() {
    vcs_info
	local d
	[ ${#PWD} -gt 30 ] && d=/${(j:/:)${(SI:4:)${(@s:/:):-${(%):-%~}}//?}} || d=${(%):-%~}
    PS1_BASE="%F{cyan%}$d%f%F{white}$vcs_info_msg_0_%f%F{white}%#%f "
	PS1_PREFIX="%F{green}%m%f%F{white}:%f"
	# if screen is running then don't display the hostname in PS1 20131201-21:40:44
	if [ -z "$STY" ];then
    	PS1=$PS1_PREFIX$PS1_BASE
	else
		PS1=$PS1_BASE
	fi
}

precmd_functions+=( zshvcsprompt )


# ztodo 20120222-21:30:30
autoload -Uz ztodo

#
# title settings
#
function title() {
	# escape '%' chars in $1, make nonprintables visible
	local a=${(V)1//\%/\%\%}
	# truncate command, and join lines.
	a=$(print -Pn "%40>...>$a" | tr -d "\n")
	case $TERM in
		xterm*)
			print -Pn "\e]2;$a @ $2\a"
			;;  
	esac
}


#
# zsh + notifyosd 20130119-22:31:30
# original credit to:	http://mumak.net/undistract-me/
# my gist:				https://gist.github.com/4576452
#
[[ $ZPRF_LIBNOTIFY -gt 0 ]] && [ -e $HOME/.zsh/notifyosd.zsh ] && [ -x `which notify-send` ] && . $HOME/.zsh/notifyosd.zsh

# added smily face on 20130910-21:46:43
function precmd() {
	local RETVAL=$?
    title "zsh" "%m:%55<...<%~"
	if [[ $RETVAL = '0' ]]; then
		RPS1='$?=☺ ';
	else
		RPS1='$?=☹ ';
		fliptable
	fi
}

function preexec() {
    title "$1" "%m:%35<...<%~"
}

# emacs keybindings
bindkey -e

# edit command in EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey "^x^e" edit-command-line

#
#
# history settings
#
HISTSIZE=10000
SAVEHIST=10000
# switched to host-based history file on 20120412:21:39:02
# made the host-based history localized on 20130809-23:49:21
HISTDIR=$HOME/.zsh-local/history
HISTFILE=$HISTDIR/$HOST.history
df -T /home | grep nfs > /dev/null
if [[ $? == '0' ]]; then
	HISTFILE=$HISTDIR/history
else
	HISTFILE=$HISTDIR/$HOST.history
fi
[ -d $HISTDIR ] || mkdir -p $HISTDIR
[ -e $HISTFILE ] || touch $HISTFILE
setopt histignorealldups sharehistory
setopt INC_APPEND_HISTORY SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt MENUCOMPLETE
setopt ALL_EXPORT
setopt NO_CASE_GLOB


#
# misc settings
#
# Say how long a command took, if it took more than 30 seconds
export REPORTTIME=10

# why would you type 'cd dir' if you could just type 'dir'?
setopt AUTO_CD

# spell check commands
setopt CORRECT

# added 20120618:22:21:08, courtesy of Mikachu in #zsh
# don't allow () { if true; echo hello }
setopt noshortloops

# don't overwrite existing files on redirection 20120204-08:48:22
setopt NOCLOBBER


#
# completion settings
#
autoload -Uz compinit
compinit

# zstyle default options
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
[ -e $HOME/.dircolors ] && eval "$(dircolors -b $HOME/.dircolors)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
#zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# zstyle changes by me
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path $HOME/.zsh-local/cache/$HOST

# zstyle for commands
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%mem,%cpu,cputime,cmd'

# zstyle for vcs_info
# added 20130723-23:29:16
# inspired by http://arjanvandergaag.nl/blog/customize-zsh-prompt-with-vcs-info.html
zstyle ':vcs_info:*' check-for-changes true

# command not found!!!
[ -e /etc/zsh_command_not_found ] && . /etc/zsh_command_not_found

# aliases
[[ $ZPRF_ALIAS -gt 0 ]] && . $HOME/.zsh/aliases

# completion
#[ -e $HOME/.zsh/completion/_task ] && [ -x `which task` ] && . $HOME/.zsh/completion/_task

# libvte stuff
[ -e /etc/profile.d/vte.sh ] && . /etc/profile.d/vte.sh

# environment
[[ $ZPRF_ENV -gt 0 ]] && . $HOME/.zsh/environment

# builtin function overrides
. $HOME/.zsh/builtins

# my functions
[[ $ZPRF_FUNCTIONS -gt 0 ]] && . $HOME/.zsh/functions

# key bindings
. $HOME/.zsh/bindkey

# login shell autorun
[[ $ZPRF_LOGIN_AUTORUN -gt 0 ]] && . $HOME/.zsh/login
