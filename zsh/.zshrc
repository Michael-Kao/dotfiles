# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias windows='sudo efibootmgr -n 0'

# this is for pure theme
# github link: https://github.com/sindresorhus/pure
fpath+=($HOME/.zsh/pure)

export VCPKG_ROOT=/builds/vcpkg
export PATH=$VCPKG_ROOT:$PATH

export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$PATH:$GEM_HOME/bin"
export PATH="$PATH:$/home/kao/.cargo/bin"

autoload -Uz compinit promptinit
compinit
promptinit
prompt pure

# This will set the default prompt to the walters theme
#prompt walters
#
#


