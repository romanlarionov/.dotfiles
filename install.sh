#!/bin/bash

DOTFILES_DIR="${HOME}/.dotfiles"
FILES=".bashrc .zshrc .vimrc .minttyrc .gitconfig .fonts .tmux.conf .clang-format .globalrc .inputrc"

if [[ ! -d ${DOTFILES_DIR}/OldDotFiles ]]; then
    mkdir ${DOTFILES_DIR}/OldDotFiles

    echo "Caching old dotfiles files..."
    for file in ${FILES}; do
        if [[ -f  ${HOME}/${file} || -d ${HOME}/${file} ]]; then
            mv ${HOME}/${file} ${DOTFILES_DIR}/OldDotFiles
        fi
    done
fi

for file in ${FILES}; do
    ln -s ${DOTFILES_DIR}/${file} ${HOME}/${file} &> /dev/null
done

if [[ "$(lsb_release -si 2>/dev/null)" == "Ubuntu" ]]; then
    sudo apt-get install -q -y cmake wget curl clang-format cscope xfonts-utils
fi

if [[ "${uname}" == "Darwin" ]]; then
    if [[ $(command -v brew) == "" ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew install git brew-cask cmake wget vim global ctags cscope ag
        brew linkapps
    else
        brew update
    fi
fi

