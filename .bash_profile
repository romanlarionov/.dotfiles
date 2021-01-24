
# see /usr/share/doc/bash/examples/startup-files for examples

if [ -n "${BASH_VERSION}" ]; then
    if [ -f "${HOME}/.bashrc" ]; then
	. "${HOME}/.bashrc"
    fi
fi

if [[ -z "${ROMANS_TAGS_PATH}" ]]; then
    mkdir -p "$HOME/.tags"
    export ROMANS_TAGS_PATH="$HOME/.tags"
fi

PATH="${HOME}/bin:${HOME}/.local/bin:$PATH"

if [[ -d "${HOME}/.dotfiles" ]]; then
    if [[ ${PATH} != *".dotfiles/scripts"* ]]; then
        PATH="${HOME}/.dotfiles/scripts:${PATH}"
    fi

    if [[ "${OSTYPE}" == *"msys"* ]]; then
        if [[ ${PATH} != *".dotfiles/bin/win"* ]]; then
            PATH="${PATH}:${HOME}/.dotfiles/bin/win/"
        fi
    fi

    # colors break sftp/scp
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        if [[ -n "${SSH_TTY}" ]]; then
            # Setup terminal colors
            BASE16_SHELL="${HOME}/.dotfiles/base16-eighties.sh"
            [[ -s ${BASE16_SHELL} ]] && source ${BASE16_SHELL}
        fi
    else
        BASE16_SHELL="${HOME}/.dotfiles/base16-eighties.sh"
        [[ -s ${BASE16_SHELL} ]] && source ${BASE16_SHELL}
    fi
fi

if [[ ! -z "${ROMANS_PATH}" ]]; then
    PATH="${ROMANS_PATH}:${PATH}"
fi

export PATH
