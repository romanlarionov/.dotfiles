#!/bin/bash

DOTFILES_DIR="${HOME}/.dotfiles"
FILES=".bashrc .zshrc .vimrc .minttyrc .gitconfig .fonts .tmux.conf .clang-format .globalrc .gitignore.global"

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

    if [[ ${ZSH_REPLY} =~ ^[Yy]$ ]]; then
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
        brew install git brew-cask cmake wget vim global ctags cscope ag
        brew linkapps

        if [[ ${ZSH_REPLY} =~ ^[Yy]$ ]]; then
            brew install zsh
        fi
    else
        brew update
    fi
fi

