eval `ssh-agent -s` #Turning on SSH-Agent

# Fixing global terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# ALIASES CUSTOM
alias pull-all='find . -type d -name .git -execdir git pull -v ";"'
alias cls='clear'
alias cd..='cd ..'

clear
