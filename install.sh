#!/bin/bash

DOTFILES_DIR="${HOME}/.dotfiles"
FILES=".bashrc .zshrc .vimrc .minttyrc .gitconfig .fonts .clang-format .globalrc .inputrc .profile"

# save any dotfiles in the above list that were detected in the home directory
if [[ ! -d ${DOTFILES_DIR}/OldDotFiles ]]; then
    mkdir ${DOTFILES_DIR}/OldDotFiles
fi

# if we've already run the install script before, rename the _last set of OldDotFiles
LAST_DOTFILES_DIR="$(ls ${DOTFILES_DIR} | grep "_last")"
if [[ -z "${LAST_DOTFILES_DIR}" ]]; then
    mv ${LAST_DOTFILES_DIR} "$(echo ${LAST_DOTFILES_DIR} | cut -d'_' -f 1)"
fi

CURR_OLD_DOTFILES_DIR="${DOTFILES_DIR}/OldDotFiles/${RANDOM}_last"
mkdir ${CURR_OLD_DOTFILES_DIR}

for file in ${FILES}; do
    if [[ -f  ${HOME}/${file} || -d ${HOME}/${file} ]]; then

        # only move the files if they aren't already symlinked to the .dotfiles dir
        if [[ ! -L ${HOME}/${file} ]]; then
            mv ${HOME}/${file} ${CURR_OLD_DOTFILES_DIR}
        fi
    fi
done

# make symlinks for listed dotfiles
for file in ${FILES}; do
    if [[ ! -L ${HOME}/${file} ]]; then
        ln -s ${DOTFILES_DIR}/${file} ${HOME}/${file} &> /dev/null
    fi
done

if [[ "$(lsb_release -si 2>/dev/null)" == "Ubuntu" ]]; then
    sudo apt-get install -q -y cmake wget curl clang-format cscope xfonts-utils

elif [[ "${uname}" == "Darwin" ]]; then
    if [[ $(command -v brew) == "" ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew install brew-cask cmake wget vim global ctags cscope ag
        brew linkapps
    else
        brew update
    fi
fi

