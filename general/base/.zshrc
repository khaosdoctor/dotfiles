#!/usr/bin/env zsh
autoload -U compinit; compinit

# LOADS USER EXPORTS VARIABLES
if [[ -a $HOME/.exports ]]; then
  source $HOME/.exports
fi

# LOADS USER FUNCTIONS
if [[ -a $HOME/.functions ]]; then
  source $HOME/.functions
fi

# LOADS USER ALIASES
if [[ -a $HOME/.aliases ]]; then
  source $HOME/.aliases
fi

# Enable check for both fastfetch and neofetch in case one of them is not installed
if [ "$(tput lines)" -ge 25 ] && command -v fastfetch >/dev/null; then 
    fastfetch
elif [ "$(tput lines)" -ge 25 ] && command -v neofetch >/dev/null; then 
    neofetch 
fi;

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
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify

# The following lines were added by compinstall
zstyle :compinstall filename '/home/khaosdoctor/.zshrc'

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

 export EDITOR='nvim'

##### OS SPECIFIC CONFIGS #######

# MacOS
if [[ $(uname -s) == "Darwin" ]]; then
  bindkey -v
  # brew installed
  if type brew &>/dev/null
  then
    # Initiate ASDF on mac
    [ -f $(brew --prefix asdf)/libexec/asdf.sh ] && source $(brew --prefix asdf)/libexec/asdf.sh
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  fi

  $DOTFILES/specific/darwin/non-stowable/one-time-commands/run-one-time-commands.sh
fi

# Linuxes
if [[ $(uname -s) == "Linux" ]]; then

  # Correct control keys on linux
  bindkey "^[[3~" delete-char # Delete
  bindkey "^[[H" beginning-of-line # Home
  bindkey "^[[F" end-of-line # End

  # Depending on the session type we change GNOME's drun command
  if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ -x "$(command -v dconf)" ]; then
      # Wofi does not open in wayland
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'wofi --show drun'"
  elif [ "$XDG_SESSION_TYPE" = "x11" ] && [ -x "$(command -v dconf)" ]; then
      # Rofi opens in Wayland but bugs out
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'rofi -show combi'"
  fi

fi

################################

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"

# if startupscripts is a dir
if [[ -d $HOME/.startupscripts ]]; then
  chmod -R +x $HOME/.startupscripts
  cd $HOME/.startupscripts
  find . -type f -name "*.sh" -exec {} \;
  cd $HOME
# is a regular file
elif [[ -f $HOME/.startupscripts ]]; then
  # can be executed
  if [[ -x $HOME/.startupscripts ]]; then
    bash $HOME/.startupscripts &
  fi
fi

# To customize prompt, run `p10k configure` or edit ~/Documents/Repositories/github.com/khaosdoctor/dotfiles/Global/.p10k.zsh.
[[ ! -f ~/Documents/Repositories/github.com/khaosdoctor/dotfiles/Global/.p10k.zsh ]] || source $HOME/.p10k.zsh

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Load local overrides not tracked by git
if [ -f "$HOME/.localoverrides" ]; then
  source "$HOME/.localoverrides"
fi

autoload -Uz compinit
fpath+=~/.zfunc

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/lsantos/.docker/completions $fpath)
# End of Docker CLI completions
