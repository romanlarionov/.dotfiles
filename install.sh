#!/bin/bash
############################
# install.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/.dotfiles
############################

########## First Time install

if [[ ! -d "$HOME/.dotfiles/.roman" ]]; then
	cd ~/.dotfiles
	mkdir .roman
	echo "First time installing."
	
	echo "Installing Homebrew."
	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"	
	echo "done"

	echo "Installing Brew Cask."
	brew install brew-cask
	echo "done"

	echo "Installing VIM"
	brew install vim
	echo "done"

	echo "Installing Pathogen"
	mkdir -p ~/.vim/autoload ~/.vim/bundle && \
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	echo "done"

	cd ~/
fi

########## Variables

dir=~/.dotfiles                    # dotfiles directory
files=".vimrc .vim .zshrc .oh-my-zsh .gitconfig .hydra"    # list of files/folders to symlink in homedir
platform=$(uname);
iTerm_version='_v1_0_0';

##########

# Change to the dotfiles directory.
echo -n "Changing to the dotfiles directory ..."
cd $dir
echo "done"

# Move any existing dotfiles in ~/ to ~/.dotfiles, then create symlinks from ~/ to any files in ~/.dotfiles specified in $files
for file in $files; do
    echo "Copying file/folder to home directory."
    cp $file ~/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done

# Mac OS X specific configuration.
if [[ $platform == 'Darwin' ]]; then
    
    # if iTerm isn't already installed 
    if [[ ! -d "~/Applications/iTerm.app" ]]; then
	read -p "iTerm2 is not installed, would you like to do that now (y/n) " yn

	# Only install if the user wants to.
	if [[ $yn == [Yy]* ]]; then 
            # Download iTerm2.
            echo 'Grabbing iTerm'
            curl -o iterm.zip http://www.iterm2.com/downloads/stable/iTerm2_v1_0_0.zip
	    	cd $dir
            unzip iterm.zip
            mv iTerm.app ~/Applications
            rm -r iterm.zip
	    	echo "Finshed installing iTerm2"
	     
            # Download iTerm2 Monokai color scheme.
            if [[ ! -d "$dir/colorscheme" ]]; then
				echo "Installing iTerm2 Monokai color scheme." 
				mkdir $dir/colorscheme
				cd $dir/colorscheme
				git clone https://github.com/dawnerd/monokai-iterm
				cd $dir
	 	    fi
		fi
    fi 
fi

install_zsh () {
# Test to see if zshell is installed.  If it is:
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Clone my oh-my-zsh repository from GitHub only if it isn't already present
    if [[ ! -d $dir/.oh-my-zsh/ ]]; then
        git clone http://github.com/robbyrussell/oh-my-zsh.git
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
        chsh -s $(which zsh)
    fi
else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
        sudo apt-get install zsh
        install_zsh
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
        echo "Please install zsh, then re-run this script!"
        exit
    fi
fi
}

install_zsh
