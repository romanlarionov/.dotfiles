#!/bin/bash
############################
dir=~/.dotfiles                    # dotfiles directory
files="spacemacs zshrc gitconfig fonts"     # list of files/folders to symlink in homedir
platform=$(uname);

cd $HOME

########## File Management

# If there exists any old dotfiles, save them and replace them with the new ones.
echo "Saving old dotfiles..."

mkdir ${dir}/.dotfiles.old
oldFiles=${dir}/.dotfiles.old

echo "Caching files..."
for file in ${files}; do
  mv .${file} ${oldFiles}
done
echo "Completed caching. Your files are safe :)"

# Update symlinked dotfiles in home directory with files located in ~/.dotfiles.
for file in ${files}; do
  echo "Copying .${file} to home directory."
  cp ${dir}/${file} ${HOME}
  mv ${file} .${file}
  echo "Creating symlink to ${file} in home directory."
  ln -s ${dir}/${file} ${HOME}/.${file}
done

# Special case
cd ${dir}

########## Ubuntu Specific

if [ "$(lsb_release -si)" == "Ubuntu" ]; then
  # Powerline fonts
  mkdir ~/.fonts
  git clone https://github.com/pdf/ubuntu-mono-powerline-ttf.git ~/.fonts/ubuntu-mono-powerline-ttf
  fc-cache -vf
  
  # Useful tools and libraries
  sudo apt-get install zsh cmake wget curl libncurses-dev
  
  # Emacs
  sudo wget http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.gz
  tar -xzf emacs-24.5.tar.gz
  cd emacs-24.5
  ./configure --without-x
  make -j4
  sudo make install
  
  # Spacemacs
  git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
fi

########## OS X Specific

if [[ $platform == 'Darwin' ]]; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew install brew-cask zsh cmake wget
  brew tap d12frosted/emacs-plus
  brew install emacs-plus --with-cocoa --with-gnutls --with-librsvg --with-imagemagick --with-spacemacs-icon
  brew linkapps

  git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
fi

########## Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s $(which zsh)

echo "done"
