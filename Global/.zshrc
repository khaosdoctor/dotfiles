# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && . "$HOME/.fig/shell/zshrc.pre.zsh"
# LOADS USER EXPORTS VARIABLES
if [[ -a $HOME/.exports ]]; then
  source $HOME/.exports
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
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

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi


autoload -Uz compinit
compinit

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-rust \
    pubnic/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk

# Loads powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Loads plugins
zinit wait lucid for \
  atinit'ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay' \
  zdharma-continuum/fast-syntax-highlighting \
  blockf \
  zsh-users/zsh-completions \
  atload'!_zsh_autosuggest_start' \
  zsh-users/zsh-autosuggestions \
  hlissner/zsh-autopair \
  zpm-zsh/colorize \
  Tarrasch/zsh-command-not-found \
  atload'alias python=python3' amstrad/oh-my-matrix \
  reegnz/jq-zsh-plugin \
  atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down;' zsh-users/zsh-history-substring-search \
  Tarrasch/zsh-colors \
  agkozak/zsh-z \
  wfxr/forgit

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='vim'
fi

# LOADS USER FUNCTIONS
if [[ -a $HOME/.functions ]]; then
  source $HOME/.functions
fi

# LOADS USER ALIASES
if [[ -a $HOME/.aliases ]]; then
  source $HOME/.aliases
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
[ -f $(brew --prefix asdf)/libexec/asdf.sh ] && source $(brew --prefix asdf)/libexec/asdf.sh

if [[ -a $HOME/.startupscripts ]]; then
  chmod +x $HOME/.startupscripts
  (nohup $HOME/.startupscripts >/dev/null 2>&1 &) > /dev/null 2>&1
fi

# To customize prompt, run `p10k configure` or edit ~/Documents/Repositories/github.com/khaosdoctor/dotfiles/Global/.p10k.zsh.
[[ ! -f ~/Documents/Repositories/github.com/khaosdoctor/dotfiles/Global/.p10k.zsh ]] || source ~/Documents/Repositories/github.com/khaosdoctor/dotfiles/Global/.p10k.zsh

. $(brew --prefix asdf)/libexec/asdf.sh

# bun completions
[ -s "/Users/khaosdoctor/.bun/_bun" ] && source "/Users/khaosdoctor/.bun/_bun"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && . "$HOME/.fig/shell/zshrc.post.zsh"
