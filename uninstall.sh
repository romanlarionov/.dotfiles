#!/bin/bash

DOTFILES_DIR="${HOME}/.dotfiles"
OLD_DOTFILES_DIR="${DOTFILES_DIR}/OldDotFiles"
source ${DOTFILES_DIR}/.files

if [[ -d "${OLD_DOTFILES_DIR}" ]]; then
    # find the directory with _last in OldDotFiles
    LAST_DOTFILES="$(ls ${OLD_DOTFILES_DIR} | grep "_last")"
    echo "Restoring previous dotfiles from here: ${LAST_DOTFILES}"
    
    for file in ${FILES}; do
        rm -rf ${HOME}/${file}
    done
    				
    for file in ${LAST_DOTFILES}; do
        mv ${LAST_DOTFILES}/${file} ${HOME}/${file}
    done
    
    cd ${HOME}
    rm -rf ${DOTFILES_DIR}
fi

