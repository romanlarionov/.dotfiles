#!/bin/bash
############################
# install.sh
# This file is an automatic installer for all of 
# Roman Larionov's dotfiles and specialized configurations. 
#
# To use, simply run : $ sh install.sh
#
# Remember to add installer for YouCompleteMe essentials, including:
# 		XCode latest release, MacVim, XBuild
#
########### Variables

dir=~/.dotfiles                    # dotfiles directory
files="vimrc vim oh-my-zsh zshrc gitconfig hydra"    # list of files/folders to symlink in homedir
platform=$(uname);
iTerm_version='_v1_0_0';

########## First Time Install

cd $dir

# OS X specific initial intallations.	
if [[ $platform == 'Darwin' ]]; then
	echo "Installing Homebrew."
	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"	
	echo "done"

	echo "Installing Brew Cask."
	brew install brew-cask
	echo "done"

	echo "Installing VIM"
	brew install macvim
	echo "done"

	# if iTerm isn't already installed 
	if [[ ! -d "$HOME/Applications/iTerm.app" ]]; then
		read -p "iTerm2 is not installed, would you like to do that now (y/n) " yn

		# Only install if the user wants to.
		if [[ $yn == [Yy]* ]]; then 
			# Download iTerm2.
			echo "Installing iTerm2."
			curl -o iterm.zip http://www.iterm2.com/downloads/stable/iTerm2$iTerm_version.zip
			cd $dir
			unzip iterm.zip
			mv iTerm.app ~/Applications
			rm -r iterm.zip
			echo "Finshed installing iTerm2"
		fi
	fi
fi

# Zshell
if [[ ! $(echo $SHELL) == $(which zsh) ]]; then

	echo "Installing ZShell"	
	# If using OS X.	
	if [[ $platform == 'Darwin' ]]; then
		brew install zsh	
	fi
	echo "done"

	echo "Switching shells..."
	chsh -s $(which zsh)
	echo "done"
fi

echo "Updating git submodules..."
git submodule init
git submodule update



# If there exsists any old dotfiles, save them and replace them with the new ones.
echo "Saving old dotfiles..."

# Special case
rm -r -f ~/.oh-my-zsh

mkdir $dir/.dotfiles.old
oldFiles=~/.dotfiles/.dotfiles.old

for file in $files; do
	echo "Caching $file ..."
	mv ~/$.file $oldFiles
	echo "done"
done
echo "Completed caching. Your files are safe :)"

# Update symlinked dotfiles in home directory with files located in ~/.dotfiles.
for file in $files; do
    echo "Copying $file to home directory."
    cp $dir/.$file $HOME/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file $HOME/.$file
done


echo "

Finished installation process!

                   .--.
          : (\ ". _......_ ." /) :
           '.    `        `    .'		   ______                __       __      __  
            /'   _        _   `\		  / ____/___  ____  ____/ /      / /___  / /_ 
           /     0}      {0     \		 / / __/ __ \/ __ \/ __  /  __  / / __ \/ __ \
          |       /      \       |		/ /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / /_/ /
          |     /'        `\     |		\____/\____/\____/\__,_/   \____/\____/_.___/ 
           \   | .  .==.  . |   /
            '._ \.' \__/ './ _.'
            /  ``'._-''-_.'``  \
                    `--`
"


