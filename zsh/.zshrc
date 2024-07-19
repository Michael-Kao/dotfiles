# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'

# this is for pure theme
# github link: https://github.com/sindresorhus/pure
fpath+=($HOME/.zsh/pure)

export VCPKG_ROOT=/builds/vcpkg
export PATH=$VCPKG_ROOT:$PATH

autoload -Uz compinit promptinit
compinit
promptinit
prompt pure

# This will set the default prompt to the walters theme
#prompt walters
#
#


