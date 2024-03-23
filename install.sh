#!/bin/bash

DOTFILES_DIR="${HOME}/.dotfiles"
OLD_DOTFILES_DIR="${DOTFILES_DIR}/OldDotFiles"
source "${DOTFILES_DIR}/.files"

mkdir -p "${DOTFILES_DIR}/OldDotFiles"
mkdir -p "${HOME}/.ssh"
mkdir -p "${HOME}/.tags"

# prevent installing if a difference was detected
# only really applicable on git bash since it doesn't support symlinks
if [[ -n "$("${DOTFILES_DIR}"/check_diff.sh)" ]]; then
    echo -n "A difference was found between dotfiles. Continue? (y/n)? "
    read -r answer

    if [[ "$answer" == "${answer#[Yy]}" ]]; then
        exit
    fi
fi

# if we've already run the install script before, rename the _last set of OldDotFiles
LAST_DOTFILES_DIR="$(ls "${OLD_DOTFILES_DIR}" | grep '_last')"
if [[ -n "${LAST_DOTFILES_DIR}" ]]; then
    mv "${OLD_DOTFILES_DIR}/${LAST_DOTFILES_DIR}" \
        "${OLD_DOTFILES_DIR}/$(echo "${LAST_DOTFILES_DIR}" | cut -d'_' -f 1)"
fi

CURR_OLD_DOTFILES_DIR="${DOTFILES_DIR}/OldDotFiles/${RANDOM}_last"
mkdir -p "${CURR_OLD_DOTFILES_DIR}"
echo "Stored previous dotfiles here: ${CURR_OLD_DOTFILES_DIR}"

# save all dotfiles currently in the home directory to $CURR_OLD_DOTFILES_DIR (unless they're symlinked)
for file in ${FILES}; do
    if [[ -f  ${HOME}/${file} || -d ${HOME}/${file} ]]; then

        # only move the files if they aren't already symlinked to the .dotfiles dir
        if [[ ! -L ${HOME}/${file} ]]; then
            mv "${HOME}/${file}" "${CURR_OLD_DOTFILES_DIR}"
        fi
    fi
done

# make symlinks for listed dotfiles
# note: git bash currently doesn't support symlinks -_-
for file in ${FILES}; do
    if [[ ! -L ${HOME}/${file} ]]; then
        ln -s "${DOTFILES_DIR}/${file}" "${HOME}/${file}" &> /dev/null
    fi
done

# install default utilities for this platform
if [[ "$(lsb_release -si 2>/dev/null)" == "Ubuntu" ]]; then
    sudo apt-get install -q -y vim cmake wget curl clang-format xfonts-utils

elif [[ "$(uname)" == "Darwin" ]]; then
    if [[ -z "$(command -v brew)" ]]; then
        sudo xcodebuild -license accept
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ${HOME}/.bash_profile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        brew install brew-cask cmake wget ctags python3 ripgrep
        brew linkapps
    fi
fi

if [[ -n "$(command pip 2>/dev/null)" ]]; then
    pip install argparse Pillow numpy scipy matplotlib &>/dev/null
fi

if [[ -n "$(command pip3 2>/dev/null)" ]]; then
    pip3 install argparse Pillow numpy scipy matplotlib &>/dev/null
fi

