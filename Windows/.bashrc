eval `ssh-agent -s` #Turning on SSH-Agent

# Fixing global terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

#CUSTOM FUNCTIONS
gh_clone() {
  git clone "https://github.com/$1.git"
}

# ALIASES CUSTOM
alias pull-all='find . -type d -name .git -execdir git pull -v ";"'
alias cls='clear'
alias rimraf='rm -rf'
alias cd..='cd ..'
alias .='cd .'
alias ..='cd ..'
alias gh-clone=gh_clone
clear
