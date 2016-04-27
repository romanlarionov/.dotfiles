#!/bin/bash

dir=~/.dotfiles
files="fonts zshrc gitconfig"
oldFiles=$dir/.dotfiles.old

cd $HOME

echo "Removing all dotfiles within your home directory..."
rm -rf ~/.oh-my-zsh
for file in $files; do
	echo "Deleting $file ..."
	rm -rf .$file
	echo "done"
done
echo "done"
				
echo "Reverting back to your previous settings..."
cd $oldFiles
for file in $oldFiles; do
	mv $file $HOME/.$file
done

cd $HOME
rm -rf $dir
echo "Uninstall complete!"
