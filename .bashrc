
if [[ -f "${HOME}/.bashrc.local" ]]; then
    source ${HOME}/.bashrc.local
fi

if [[ -d "${HOME}/.dotfiles" ]]; then
    if [[ $PATH != *".dotfiles/scripts"* ]]; then
        PATH="${HOME}/.dotfiles/scripts:$PATH"
    fi

    # Setup terminal colors
    BASE16_SHELL="${HOME}/.dotfiles/base16-eighties.dark.sh"
    [[ -s ${BASE16_SHELL} ]] && source ${BASE16_SHELL}
fi

# Functions
rgrep() { grep -irn "$1" "$2" --color=auto; }
rfind() { find "$2" -name "$1"; }

setup_ssh_agent()
{
    SSH_AGENT_TIMEOUT=9000 # 2.5 hours
    env=~/.ssh/agent.env

    # setup environment
    test -f "$env" && . "$env" >| /dev/null;

    # AGENT_RUN_STATE: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
    AGENT_RUN_STATE=$(ssh-add -l >| /dev/null 2>&1; echo $?)

    if [ ! "${SSH_AUTH_SOCK}" ] || [ ${AGENT_RUN_STATE} = 2 ]; then
        # start agent
        (umask 077; ssh-agent >| "$env")
        . "$env" >| /dev/null;

        # assumes name of key is id_rsa
        ssh-add -q -t ${SSH_AGENT_TIMEOUT} >| /dev/null
    elif [ "${SSH_AUTH_SOCK}" ] && [ ${AGENT_RUN_STATE} = 1 ]; then
        ssh-add -q -t ${SSH_AGENT_TIMEOUT} >| /dev/null
    fi

    unset env
}

# If running a git command for the first time, setup ssh-agent
g()
{
    # todo: need to only run when git would normally request a password (not on git status)
    # todo: if a new terminal window is openned (with ssh-agent process still running in the background),
    #       SSH_AGENT_PID might not be set, so the else branch here is taken when it shouldn't
    if ps -p ${SSH_AGENT_PID} &>/dev/null
    then
        git "$@"
    else
        setup_ssh_agent
        git "$@"
    fi
}

open()
{
    if [[ "$OSTYPE" == "msys" ]]; then
        explorer.exe "${@////\\}" # replace slashes with backslashes (for windows)
    else
        open "$@"
    fi
}

# Aliases
alias ls="ls -G --color=auto"
alias la="ls -a"
alias ll="ls -l"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep -i --color=auto"
alias ebrc="vim ${HOME}/.bashrc"
alias sbrc="source ${HOME}/.bashrc > /dev/null"
alias p3="python3"

