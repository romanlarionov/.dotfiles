!/bin/bash
############################
# install.sh
# This file is an automatic installer for all of
# Roman Larionov's dotfiles and specialized configurations.
#
# To use, simply run : $ sh install.sh
#
########### Variables
platform=$(uname);

# OS X
if [[ $platform == 'Darwin' ]]; then
    git clone -b osx https://github.com/HowdyDutty/.dotfiles.git
# Windows
elif [[ $platform == 'UWIN' ]]; then
    git clone -b windows https://github.com/HowdyDutty/.dotfiles.git	
fi
