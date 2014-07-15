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

if [[ ! -d "$HOME/.dotfiles/.roman" ]]; then
	cd $dir
	mkdir .roman
	echo "First time installing."

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

	cd $HOME
fi

########## Frequently Updated Commands

 Update symlinked dotfiles in home directory with files located in ~/.dotfiles.
for file in $files; do
    echo "Copying $file to home directory."
    cp $dir/$.file $HOME/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file $HOME/.$file
done

