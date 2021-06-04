export NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules
export NVM_AUTO_USE=true
export GOPATH=/Users/khaosdoctor/gopath
# Adds current path to node
export KUBE_EDITOR='vim'
# Exports my own binaries
export PATH=$PATH:/Users/khaosdoctor/bin
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export DENO_INSTALL="/home/khaosdoctor/.deno"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Fixing completions
setopt automenu nolistambiguous
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify

# The following lines were added by compinstall
zstyle :compinstall filename '/home/khaosdoctor/.zshrc'

autoload -Uz compinit
compinit

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

zinit load agkozak/zsh-z
### End of Zinit's installer chunk

# Loads powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Loads plugins
zinit wait lucid for \
  atinit'ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay' \
  zdharma/fast-syntax-highlighting \
  blockf \
  zsh-users/zsh-completions \
  atload'!_zsh_autosuggest_start' \
  zsh-users/zsh-autosuggestions \
  hlissner/zsh-autopair \
  zpm-zsh/colorize \
  Tarrasch/zsh-command-not-found \
  lukechilds/zsh-nvm \
  atload'alias python=python3' amstrad/oh-my-matrix \
  reegnz/jq-zsh-plugin \
  atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down;' zsh-users/zsh-history-substring-search \
  Tarrasch/zsh-colors

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='vim'
fi

alias zshconfig="vim ~/.zshrc"
alias reload!="source ~/.zshrc"

#CUSTOM FUNCTIONS
ghc () {
  local user=`basename $(pwd)`
  git clone "https://github.com/$user/$1.git"
}

git_goto () {
  find . -name .git -type d -execdir git checkout $1 ";"
}

docker_prune () {
  docker rmi `docker images | awk '{ print $3; }'`
}

mkcd () {
  mkdir -p $1 && cd $1
}

# ALIASES CUSTOM
alias lsr='tree -ChDvL $1 $2'
alias pull-all='find . -type d -name .git -execdir git pull -v ";"'
alias update-all='/usr/local/bin/update-all'
alias rm='rm -rf'
alias cls='clear'
alias cd..='cd ..'
alias ..='cd ..'
alias ll='ls -l'
alias la='ls -la'
alias l='ls'
alias lh='ls -lh'
alias git-goto=git_goto
alias ftp=lftp
alias k=kubectl
alias kx=kubectx
alias kn=kubens
alias dkr=docker
alias dkrc=docker-compose

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
function gi() { curl -sLw n https://www.toptal.com/developers/gitignore/api/$@ ;}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
