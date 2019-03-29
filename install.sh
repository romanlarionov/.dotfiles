#!/bin/bash

DOTFILES_DIR="${HOME}/.dotfiles"
FILES=".SpaceVim.d .bashrc .zshrc .gitconfig .fonts .tmux.conf .clang-format" # list of files/folders to symlink in homedir

# File Management
read -p "Do you want to install zsh? (y/n): " -n 1 -r ZSH_ANSWER
echo
read -p "Do you want to install Spacevim? (y/n): " -n 1 -r SPACEVIM_ANSWER
echo

if [[ ! -d ${DOTFILES_DIR}/OldDotFiles ]]; then
    mkdir ${DOTFILES_DIR}/OldDotFiles

    echo "Caching old dotfiles files..."
    for file in ${FILES}; do
        if [[ -f  ${HOME}/${file} || -d ${HOME}/${file} ]]; then
            mv ${HOME}/${file} ${DOTFILES_DIR}/OldDotFiles
        fi
    done

    echo "Updating new dotfiles"
    for file in ${FILES}; do
        ln -s ${DOTFILES_DIR}/${file} ${HOME}/${file}
    done
fi

if [[ "$(lsb_release -si 2>/dev/null)" == "Ubuntu" ]]; then
    sudo apt-get install -q -y cmake wget curl clang-format cscope xfonts-utils

    if [[ $ZSH_REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get install -q -y zsh
    fi
    
    # Powerline fonts
    if [[ ! -d ${DOTFILES_DIR}/.fonts/ubuntu ]]; then
        git clone https://github.com/pdf/ubuntu-mono-powerline-ttf.git ${DOTFILES_DIR}/.fonts/ubuntu
        sudo cp -f ${DOTFILES_DIR}/.fonts/ubuntu/*.ttf /usr/share/fonts/truetype
        sudo cp -f ${DOTFILES_DIR}/.fonts/ubuntu/*.otf /usr/share/fonts/opentype
        fc-cache -vf
    fi
fi

if [[ "${uname}" == "Darwin" ]]; then
    if [[ $(command -v brew) == "" ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew install git brew-cask cmake wget
        brew linkapps

        if [[ $ZSH_REPLY =~ ^[Yy]$ ]]; then
            brew install zsh
        fi
    else
        brew update
    fi
fi
    
if [[ $SPACEVIM_ANSWER =~ ^[Yy]$ ]]; then
    curl -sLf https://spacevim.org/install.sh | bash
fi

if [[ $ZSH_REPLY =~ ^[Yy]$ ]]; then
    if [[ "${SHELL}" != "zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" >/dev/null

        if [[ "${SHELL}" == "zsh" ]]; then
            chsh -s $(which zsh)

            read -p "ZSH requires reboot for complete installation. Do it now? (y/n): " -n 1 -r
            if [[ $ZSH_REPLY =~ ^[Yy]$ ]]; then
            	sudo shutdown -r now
            fi
        else
            echo "ZSH failed to install."
        fi
    fi
fi

echo "done"
