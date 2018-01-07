#!/bin/bash
OPTIONS="Linux MacOS Quit"

linux_bootstrap () {
  echo "Executing Linux bootstrap"

  echo "Installing ZSH and dependencies"
  sudo apt-get update
  sudo apt-get install -y zsh wget curl git

  echo "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  echo "Removing older files"
  rm -rf ~/.gemrc ~/.gitexcludes ~/.vimrc ~/.zshrc

  echo "Linking new files to home"
  for $dotfile in ./Global/.*; do
    local dotfileName=$(echo $dotfile | awk -F/ '{ print $3 }')
    echo "Linking $dotfileName to ~/$dotfileName"
    ln $dotfile ~/$dotfileName
  done

  echo "Removing .bashrc and .gitconfig"
  rm -rf ~/.bashrc ~/.gitconfig

  echo "Linking .bashrc and .gitconfig to your home at $(echo ~)"
  ln ./Linux/.bashrc ~/.bashrc
  ln ./Linux/.gitconfig ~/.gitconfig

  echo "Creating ZSH completions folder"
  if [ -d "~/.zsh" ]; then
    mkdir ~/.zsh
  fi

  if [ -d "~/.zsh/completions" ]; then
    mkdir ~/zsh/completions
  fi

  echo "Linking completions file to ~/zsh/completions"
  for file in ./Global/zshCompletions/*; do
    local fileName=$(echo $file | awk -F/ '{ print $4 }')
    echo "Linking $file to ~/.zsh/completions/$fileName"
    ln $file ~/.zsh/completions/$fileName
  done

  echo "Downloading Fira Code font from NerdFonts"
  curl https://github.com/ryanoasis/nerd-fonts/releases/download/v1.2.0/FiraCode.zip --create-dirs -o ~/.dotbootstrap/fira.zip
  if [ -d "~/.fonts" ]; then
    mkdir ~/.fonts
  fi
  cd ~/.fonts
  unzip ~/.dotbootstrap/fira.zip

  echo "Installing ZSH Plugins"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
  clear
  echo "Installing FZF, remember to aswer Y to all questions"
  sleep 5
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
}

mac_bootstrap () {
  echo "Executing Mac bootstrap"
}

show_completion_message () {
  echo "Instalation completed"
  echo "--- IMPORTANT MANUAL STEPS ---"
  echo "1 - Change your terminal font to Fira Code Nerdfont"
  echo "2 - Restart your terminal for changes to take effect"
  echo "3 - Enter your Vim and run :PlugInstall to install all plug-ins"
}

echo "Which OS are you using?"
select opt in $OPTIONS; do
    if [ "$opt" = "Quit" ]; then
        echo "Bye!"
        exit 0
    elif [ "$opt" = "Linux" ]; then
        linux_bootstrap
        show_completion_message
        exit
    elif [ "$opt" = "MacOS" ]; then
        mac_bootstrap
        show_completion_message
        exit
    else
        clear
        echo "Bad option"
    fi
done
