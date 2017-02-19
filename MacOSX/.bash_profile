eval `ssh-agent -s` #Turning on SSH-Agent
ssh-add pemfiles 2>/dev/null

# Fixing global terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

#CUSTOM FUNCTIONS
gh_clone() {
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

# CHECK FOR COMPLETION
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# GIT PROMPT
if [ -f /usr/local/share/gitprompt.sh ]; then
  GIT_PROMPT_THEME=Default
  . /usr/local/share/gitprompt.sh
fi

clear
