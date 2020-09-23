#!/bin/bash
#
# Check if the dotfiles located within the $HOME directory contains any
# differences from their counterparts in the $HOME/.dotfiles directory.
#

DOTFILES_DIR="${HOME}/.dotfiles"
source "${DOTFILES_DIR}/.files"

for file in ${FILES}; do
    if [[ -f  ${HOME}/${file} || -d ${HOME}/${file} ]]; then

        # only move the files if they aren't already symlinked to the .dotfiles dir
        if [[ ! -L ${HOME}/${file} ]]; then

            if [[ -n "$(diff "${HOME}/${file}" "${file}")" ]]; then
                diff -q "${HOME}/${file}" "${DOTFILES_DIR}/${file}"
            fi
        fi
    fi
done

