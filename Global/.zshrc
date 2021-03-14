# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules
export NVM_LAZY_LOAD=true
export NVM_AUTO_USE=true
export GOPATH=/Users/khaosdoctor/gopath

# Exports my own binaries
export PATH=$PATH:/Users/khaosdoctor/bin
# Exports Flutter
export PATH=$PATH:~/flutter/bin
# Export NPM Path
export PATH=$PATH:/usr/local/lib/node_modules
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export DENO_INSTALL="/home/khaosdoctor/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#LAMBDA_NEW_LINE=$'\n'
#ZSH_THEME="lambda/lambda-mod"
#ZSH_THEME="node/node"
SPACESHIP_PROMPT_ORDER=(
  #time          # Time stampts section
  #user          # Username section
  #host          # Hostname section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  #hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  ruby          # Ruby section
  #elixir        # Elixir section
  xcode         # Xcode section
  #swift         # Swift section
  golang        # Go section
  php           # PHP section
  rust          # Rust section
  #haskell       # Haskell Stack section
  #julia         # Julia section
  #docker        # Docker section
  aws           # Amazon Web Services section
  #venv          # virtualenv section
  #conda         # conda virtualenv section
  #pyenv         # Pyenv section
  #dotnet        # .NET section
  #ember         # Ember.js section
  kubectl_context
  line_sep      # Line break
  jobs          # Backgound jobs indicator
  char          # Prompt character
)
SPACESHIP_DIR_TRUNC_PREFIX=".../"
SPACESHIP_DIR_COLOR=yellow
SPACESHIP_KUBECONTEXT_PREFIX="at "
SPACESHIP_DIR_PREFIX=" "
SPACESHIP_PACKAGE_SYMBOL=" "
SPACESHIP_RUBY_SYMBOL=" "
SPACESHIP_SWIFT_SYMBOL=" "
SPACESHIP_GOLANG_SYMBOL=" "
SPACESHIP_PYENV_SYMBOL=" "
SPACESHIP_KUBECONTEXT_SYMBOL="⎈ "
SPACESHIP_JOBS_SYMBOL=" "
SPACESHIP_PACKAGE_PREFIX=" "
SPACESHIP_GIT_STATUS_PREFIX="|"
SPACESHIP_GIT_STATUS_SUFFIX="|"
SPACESHIP_GIT_BRANCH_PREFIX="[ "
SPACESHIP_GIT_BRANCH_SUFFIX="]"
SPACESHIP_GIT_STATUS_ADDED="  "
SPACESHIP_GIT_STATUS_MODIFIED="  "
SPACESHIP_GIT_STATUS_UNTRACKED="  "
SPACESHIP_GIT_STATUS_STASHED="  "
SPACESHIP_GIT_STATUS_BEHIND="  Needs Pull "
SPACESHIP_GIT_STATUS_AHEAD="  Needs Push "
SPACESHIP_HOST_PREFIX="@"
SPACESHIP_PROMPT_PREFIXES_SHOW=true
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_PREFIX=" "
SPACESHIP_CHAR_SYMBOL="𝝺 "
SPACESHIP_USER_PREFIX=""
SPACESHIP_USER_SUFFIX=""
#SPACESHIP_USER_SHOW=always
#SPACESHIP_HOST_SHOW=always
ZSH_THEME="spaceship"



#POWERLEVEL9k_MODE="nerdfont-complete"
#POWERLEVEL9K_HOME_ICON=''
#POWERLEVEL9K_HOME_SUB_ICON=''
#POWERLEVEL9K_FOLDER_ICON=''
#POWERLEVEL9K_PROMPT_ON_NEWLINE=true
#POWERLEVEL9K_TIME_FORMAT="%D{%H:%M  %d/%m/%y}"
#POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
#POWERLEVEL9K_SHOW_CHANGESET=true
#POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_left"
#POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%{%F{249}%}\u250f"
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%F{249}%}\u2517%{%F{default}%}𝝺 "
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir dir_writable vcs background_jobs)
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(nvm time)
#ZSH_THEME="powerlevel9k/powerlevel9k"
#ZSH_THEME="agnoster"
#ZSH_THEME="bureau"
#ZSH_THEME="zeta/zeta"
#ALIEN_THEME="red"
#ZSH_THEME="alien/alien"
DEFAULT_USER="khaosdoctor"
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"
# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textvim ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colorize compleat cp z docker gitignore redis-cli zsh-autosuggestions zsh-better-npm-completion zsh-nvm jsontools fast-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias reload!="source ~/.zshrc"

# Ignore jrnl entries from history search
setopt HIST_IGNORE_SPACE

#CUSTOM FUNCTIONS
gh_clone () {
  git clone "https://github.com/$1.git"
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
alias gh-clone=gh_clone
alias git-goto=git_goto
alias ftp=lftp
alias k=kubectl
alias kx=kubectx
alias kn=kubens
alias dkr=docker
alias dkrc=docker-compose
alias explorer="powershell.exe ii $1"

# Adds hub as an alias of git
eval "$(hub alias -s)"

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
source ~/.lazy_nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Adds current path to node
export NODE_PATH=./
export KUBE_EDITOR='vim'

# Exports my own binaries
export PATH=$PATH:/Users/khaosdoctor/bin
# Exports Flutter
export PATH=$PATH:~/flutter/bin
# Export NPM Path
export PATH=$PATH:/usr/local/lib/node_modules
# Export path for kubebuilder
export PATH=$PATH:/usr/local/kubebuilder/bin
#GOlang
export PATH=$PATH:$(go env GOPATH)/bin
# Load ZSH Completions
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit

# Autoloads kubectl completions
source <(kubectl completion zsh)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/khaosdoctor/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/khaosdoctor/google-cloud-sdk/path.zsh.inc'; fi

# Loads DirEnv
eval "$(direnv hook zsh)"

# added by travis gem
[ -f /Users/khaosdoctor/.travis/travis.sh ] && source /Users/khaosdoctor/.travis/travis.sh

  # Set Spaceship ZSH as a prompt
#  autoload -U promptinit; promptinit
 # prompt spaceship

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
