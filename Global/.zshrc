# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/khaosdoctor/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#LAMBDA_NEW_LINE=$'\n'
#ZSH_THEME="lambda/lambda-mod"
#ZSH_THEME="node/node"
SPACESHIP_PROMPT_ORDER=(
  time          # Time stampts section
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  #hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  ruby          # Ruby section
  elixir        # Elixir section
  xcode         # Xcode section
  swift         # Swift section
  golang        # Go section
  php           # PHP section
  rust          # Rust section
  #haskell       # Haskell Stack section
  #julia         # Julia section
  #docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  #dotnet        # .NET section
  ember         # Ember.js section
  #kubecontext   # Kubectl context section
  line_sep      # Line break
  jobs          # Backgound jobs indicator
  char          # Prompt character
)
SPACESHIP_DIR_PREFIX=" "
SPACESHIP_PACKAGE_SYMBOL=""
SPACESHIP_RUBY_SYMBOL=" "
SPACESHIP_SWIFT_SYMBOL=" "
SPACESHIP_GOLANG_SYMBOL=" "
SPACESHIP_PYENV_SYMBOL=" "
SPACESHIP_KUBECONTEXT_SYMBOL="⎈ "
SPACESHIP_JOBS_SYMBOL=""
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
SPACESHIP_PROMPT_SYMBOL="𝝺"
ZSH_THEME="spaceship/spaceship"
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
plugins=(zsh-completions git colorize compleat cp z docker gitignore redis-cli zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='mvim'
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

#CUSTOM FUNCTIONS
gh_clone () {
  git clone "https://github.com/$1.git"
}

# ALIASES CUSTOM
alias lsr='tree -aC -L $1'
alias pull-all='find . -type d -name .git -execdir git pull -v ";"'
alias update-all='/usr/local/bin/update-all'
alias rm='rm -rf'
alias cls='clear'
alias cd..='cd ..'
alias ..='cd ..'
alias ll='ls -l'
alias gh-clone=gh_clone
alias ftp=lftp
alias k=kubectl
alias dkr=docker

# Adds hub as an alias of git
eval "$(hub alias -s)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Adds current path to node
export NODE_PATH=./

# Exports my own binaries
export PATH=$PATH:/Users/khaosdoctor/bin

# Load ZSH Completions
fpath=(~/.zsh/completions $fpath) 
autoload -U compinit && compinit

# Autoloads kubectl completions
source <(kubectl completion zsh)
source <(helm completion zsh)
# Exports yarn path
export PATH="$(yarn global bin):$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/khaosdoctor/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/khaosdoctor/google-cloud-sdk/path.zsh.inc'; fi

# Loads Pyenv
eval "$(pyenv init -)"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/khaosdoctor/.config/yarn/global/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/khaosdoctor/.config/yarn/global/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/khaosdoctor/.config/yarn/global/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/khaosdoctor/.config/yarn/global/node_modules/tabtab/.completions/sls.zsh
