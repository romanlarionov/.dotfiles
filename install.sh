#!/bin/bash

DOTFILES_DIR="${HOME}/.dotfiles"
FILES=".SpaceVim.d .zshrc .gitconfig .fonts .tmux.conf .clang-format" # list of files/folders to symlink in homedir

########## File Management

echo "Saving old dotfiles..."
if [[ ! -d ${DOTFILES_DIR}/OldDotFiles ]]; then
    mkdir ${DOTFILES_DIR}/OldDotFiles

    echo "Caching old dotfiles files..."
    for file in ${FILES}; do
        mv ${HOME}/${file} ${DOTFILES_DIR}/OldDotFiles
    done
    
    echo "Updating new dotfiles"
    for file in ${FILES}; do
        ln -s ${DOTFILES_DIR}/${file} ${HOME}/${file}
    done
fi

########## Ubuntu Specific
if [[ "$(lsb_release -si)" == "Ubuntu" ]]; then
    sudo apt-get install -q -y zsh cmake wget curl

    # todo: make sure spacevim works here
    
    # Powerline fonts
    if [[ ! -d ${DOTFILES_DIR}/.fonts/ubuntu ]]; then
        git clone https://github.com/pdf/ubuntu-mono-powerline-ttf.git ${DOTFILES_DIR}/.fonts/ubuntu
        sudo cp -f ${DOTFILES_DIR}/.fonts/ubuntu/*.ttf /usr/share/fonts/truetype
        sudo cp -f ${DOTFILES_DIR}/.fonts/ubuntu/*.otf /usr/share/fonts/opentype
        fc-cache -vf
    fi
fi

########## macOS Specific
if [[ "${uname}" == "Darwin" ]]; then
    # Homebrew
    if [[ $(command -v brew) == "" ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew install git brew-cask zsh cmake wget
        brew linkapps
    else
        brew update
    fi
fi
    
########## SpaceVim
curl -sLf https://spacevim.org/install.sh | bash

if [[ "${SHELL}" != "zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" >/dev/null
    if [[ "${SHELL}" == "zsh" ]]; then
        chsh -s $(which zsh)
    fi
fi

echo ""
echo "done"
echo "NOTE: ZSH requires reboot for complete installation"
echo -n "Do it now? (y/n): "
read ANSWER
if [[ $(echo "${ANSWER}" | grep -iq "^y") ]]; then
	sudo shutdown -r now
fi
