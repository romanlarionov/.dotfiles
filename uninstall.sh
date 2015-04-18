#!/bin/bash
#################################################
# uninstall.sh
#
# To use, simply run:
#
# 	$ ./uninstall.sh
#
#################################################

########## Variables

dir=~/.dotfiles
files="vimrc fonts tmux.conf zshrc gitconfig ycm_extra_conf.py"
oldFiles=$dir/.dotfiles.old

########## Deletions

cd $HOME

echo "Removing all dotfiles within your home directory..."
rm -rf ~/.oh-my-zsh
rm -rf ~/.vim
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

