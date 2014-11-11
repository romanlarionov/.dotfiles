#!/bin/bash
############################
# install.sh
# This file is an automatic installer for all of 
# Roman Larionov's dotfiles and specialized configurations. 
#
# To use, simply run: 
#	
#	$ sh install.sh
#
# ########### WARNING #############
#	This script assumes that you have GIT installed. If you 
#	do not have it installed, you need to grab it from your 
#	prefered package manager, i.e.
#	
#	$ brew install git
#	$ sudo apt-get install git
#
#	and so on...
#
# #################################
#
# TODO: add installer for YouCompleteMe essentials, including:
# 		XCode latest release, XBuild
#
########### Variables

dir=~/.dotfiles                    # dotfiles directory
files="vimrc ideavimrc tmux.conf vim oh-my-zsh zshrc gitconfig fonts mjolnir"     # list of files/folders to symlink in homedir
platform=$(uname);
iTerm_version='_v1_0_0';

cd $dir

########## OS X Specific

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

	echo "Installing npm"
	brew install npm
	echo "done"

	# if iTerm isn't already installed 
	if [[ ! -d "$HOME/Applications/iTerm.app" ]]; then
		
		# Only install if the user wants to.
		read -p "iTerm2 is not installed, would you like to do that now? | (y/n) " yn
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

########## Zshell

if [[ $(echo $SHELL) != "/bin/zsh" ]]; then
	echo "Installing ZShell"	
	
	# If using OS X.	
	if [[ $platform == 'Darwin' ]]; then
		brew install zsh	
	fi
	if [[ $platform == "Debian" ]]; then
		sudo apt-get install zsh	
	fi
	echo "done"
	
	# Windows comes pre-installed with zsh.
	
	echo "Switching shells..."
	chsh -s $(which zsh)
	echo "done"
fi

########## Git Submodules 

echo "Updating git submodules..."
git submodule init
git submodule update

echo "Installing JSHint"
npm install -g jshint
echo "done"

# YouCompleteMe does not support Windows.
if [ $OSTYPE != "cygwin" ]; then
	read -p "Do you want to install YouCompleteMe error detection? | (y/n) " yn1
	if [[ $yn1 == [Yy]* ]]; then
		# YouCompleteMe compilation
		YCM_DIR=$dir/vim/bundle/YouCompleteMe
		clangSupp=""
		dotNetSupp=""

		read -p "Do you want to have semantic support for C-type languages? | (y/n) " yn2
		if [[ $yn2 == [Yy]* ]]; then 
			clangSupp="--clang-completer"
		fi

		read -p "Do you want to have semantic support for .Net/C# ? | (y/n) " yn3
		if [[ $yn3 == [Yy]* ]]; then
			dotNetSupp="--omnisharp-completer"	
		fi
		
		cd $YCM_DIR
		git submodule update --init --recursive
		./install.sh $clangSupp $dotNetSupp
	fi
fi

cd $HOME

########## File Management

# If there exsists any old dotfiles, save them and replace them with the new ones.
echo "Saving old dotfiles..."

# Special case
if [ -d "$HOME/.oh-my-zsh" ]; then
	echo "Deleting current version of oh-my-zsh."
	rm -rf $HOME/.oh-my-zsh
	echo "done"
fi

mkdir $dir/.dotfiles.old
oldFiles=$dir/.dotfiles.old

for file in $files; do
	echo "Caching $file ..."
	mv .$file $oldFiles
	echo "done"
done
echo "Completed caching. Your files are safe :)"

# Update symlinked dotfiles in home directory with files located in ~/.dotfiles.
for file in $files; do
    echo "Copying .$file to home directory."
    cp $dir/$file $HOME
    mv $file .$file
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file $HOME/.$file
done

echo "You did it. Good job."


