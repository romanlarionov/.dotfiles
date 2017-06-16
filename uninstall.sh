#!/bin/bash

dotfilesDir="~/.dotfiles"
files=".fonts .zshrc .gitconfig .tmux.conf"
oldFiles=${dotfilesDir}/oldDotfiles

cd ${HOME}

echo "Removing all dotfiles within your home directory..."
rm -rf ~/.oh-my-zsh
for file in ${files}; do
	echo "Deleting ${file} ..."
	rm -rf ${file}
	echo "done"
done
echo "done"
				
echo "Reverting back to your previous settings..."
cd ${oldFiles}
for file in ${oldFiles}; do
	mv ${file} ${HOME}/${file}
done

cd ${HOME}
rm -rf ${dotfilesDir}
echo "Uninstall complete!"
