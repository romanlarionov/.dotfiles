#!/bin/bash
#################################################
# uninstall.sh
#
# If you're fed up with all the dots in the files, 
# just run:		$ sh uninstall.sh
#################################################

########## Variables

dir=~/.dotfiles
files= "vimrc vim oh-my-zsh zshrc gitconfig hydra"

########## Deletions

cd $HOME

echo "Removing all dotfiles within your home directory..."
for file in $files; do
	echo "Deleting $file ..."
	rm -rf $.file
	echo "done"
done
echo "done"
				
echo "Removing .dotfiles directory."

rm -rf $HOME/.dotfiles  


