#!/bin/bash
############################
dotfilesDir="~/.dotfiles"
files=".zshrc .gitconfig .fonts .tmux.conf"     # list of files/folders to symlink in homedir
platform=${uname};

cd ${HOME}

########## File Management

# If there exists any old dotfiles, save them and replace them with the new ones.
echo "Saving old dotfiles..."

mkdir ${dotfilesDir}/oldDotfiles
oldFiles=${dotfilesDir}/oldDotfiles

echo "Caching files..."
for file in ${files}; do
    mv ${file} ${oldFiles}
done
echo "Completed caching."

# Update symlinked dotfiles in home directory with files located in ~/.dotfiles.
for file in ${files}; do
    echo "Creating symlink to ${file} in home directory."
    ln -s ${dotfilesDir}/${file} ${HOME}/${file}
done

cd ${dotfilesDir}

########## Ubuntu Specific
if [[ "$(lsb_release -si)" == "Ubuntu" ]]; then
    # Useful tools and libraries
    sudo apt-get install -y git zsh cmake wget curl libncurses-dev

    # Powerline fonts
    git clone https://github.com/pdf/ubuntu-mono-powerline-ttf.git .fonts/ubuntu
    cd ${dotfilesDir}/.fonts/ubuntu
    sudo cp -f *.ttf /usr/share/fonts
    fc-cache -vf
    cd ${dotfilesDir}
fi

########## macOS Specific
if [[ $platform == 'Darwin' ]]; then
    # Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install git brew-cask zsh cmake wget
    brew linkapps
fi
    
########## SpaceVim
curl -sLf https://spacevim.org/install.sh | bash
mkdir ~/.SpaceVim.d/
ln -s ${dotfilesDir}/init.vim ~/.SpaceVim.d/init.vim

########## Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s $(which zsh)

echo "done"
echo "NOTE: ZSH requires reboot for complete installation"
echo -n "Do it now? (y/n): "
read answer
if echo "$answer" | grep -iq "^y" ;then
	sudo shutdown -r now
fi
