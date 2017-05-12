#!/bin/bash
eval `ssh-agent -s` #Turning on SSH-Agent
ssh-add ~/Documents/Repositórios/GTPlan/arquivos-documentos/Chaves/*.pem 2>/dev/null

# Fixing global terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
# Will export GPG TTY key for GnuPG to work
GPG_TTY=$(tty)
export GPG_TTY

#CUSTOM FUNCTIONS
gh_clone () {
  git clone "https://github.com/$1.git"
}

# ALIASES CUSTOM
alias pull-all='find . -type d -name .git -execdir git pull -v ";"'
alias update-all='/usr/local/bin/update-all'
alias rimraf='rm -rf'
alias cls='clear'
alias cd..='cd ..'
alias ..='cd ..'
alias ll='ls -l'
alias gh-clone=gh_clone

# ZSh
[ -f ~/z.sh ] && . ~/z.sh

# CHECK FOR COMPLETION
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# GIT PROMPT
if [ -f /usr/local/share/gitprompt.sh ]; then
    GIT_PROMPT_THEME=Default
    . /usr/local/share/gitprompt.sh
fi
clear

# Iterm Shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
export PATH="/usr/local/sbin:$PATH"

# Python virtualenv
export WORKON_HOME=~/virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
