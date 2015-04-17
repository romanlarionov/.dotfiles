#!/bin/bash
############################
# install.sh
# This file is an automatic installer for all of 
# Roman Larionov's dotfiles and specialized configurations. 
#
# To use, simply run: 
#	
#	$ ./install.sh
#
########## Variables

dir=~/.dotfiles                    # dotfiles directory
files="vimrc ideavimrc xvimrc tmux.conf zshrc gitconfig fonts ycm_extra_conf.py"     # list of files/folders to symlink in homedir
platform=$(uname);
iTerm_version='_v1_0_0';

cd $HOME

########## File Management

# If there exists any old dotfiles, save them and replace them with the new ones.
echo "Saving old dotfiles..."

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

# Special case
cp $dir/vim/syntax/ ~/.vim/

cd $dir

########## OS X Specific

if [[ $platform == 'Darwin' ]]; then
	echo "Installing Homebrew."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
	elif [[ $platform == "Debian" ]]; then
		sudo apt-get install zsh	
	fi
	echo "done"
	
	# Windows comes pre-installed with zsh.
	echo "Switching shells..."
	chsh -s $(which zsh)
	echo "done"
fi

########## Vim Plugins

git clone https://github.com/gmarik/Vundle.vim $HOME/.vim/bundle/Vundle.vim
git clone https://github.com/robbyrussell/oh-my-zsh $HOME/.oh-my-zsh

vim +PluginInstall +qall

if [ $OSTYPE != "cygwin" ]; then
	
	# NPM is a pain on Windows, no JavaScript error handling for you.	
	echo "Installing JSHint"
	npm install -g jshint
	echo "done"

	# YouCompleteMe does not support Windows.
	read -p "Do you want to install YouCompleteMe error detection? | (y/n) " yn1
	if [[ $yn1 == [Yy]* ]]; then
		# YouCompleteMe compilation
		YCM_DIR=$HOME/.vim/bundle/YouCompleteMe
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

echo "You did it. Good job."

