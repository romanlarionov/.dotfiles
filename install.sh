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
    sudo apt-get install -y zsh cmake wget curl
    sudo apt install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
                        libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
                        libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
                        python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git

    # Building vim from source
    sudo apt remove vim vim-runtime gvim
    cd ${HOME}
    git clone https://github.com/vim/vim.git
    cd vim
    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp=yes \
                --enable-pythoninterp=yes \
                --with-python-config-dir=/usr/lib/python2.7/config \
                --enable-python3interp=yes \
                --with-python3-config-dir=/usr/lib/python3.5/config \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --enable-gui=gtk2 \
                --enable-cscope \
                --prefix=/usr/local
    make VIMRUNTIMEDIR=/usr/local/share/vim/vim80
    sudo make install

    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
    sudo update-alternatives --set editor /usr/bin/vim
    sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
    sudo update-alternatives --set vi /usr/bin/vim
    alias vim=/usr/local/bin/vim # might be incorrect sometimes

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
