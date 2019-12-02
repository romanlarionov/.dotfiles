
if [[ -f "${HOME}/.bashrc.local" ]]; then
    source ${HOME}/.bashrc.local
fi

print_ssh_ps1()
{
    if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
        printf "\[\e[31m\]@$(hostname)\[\e[0m\]"
    fi
}

print_git_branch_ps1()
{
    BRANCH_NAME=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ ! -z ${BRANCH_NAME} ]]; then
        HAS_UNSTAGED=$(git status 2>/dev/null | grep 'Changes not staged for commit')
        [[ -z ${HAS_UNSTAGED} ]] && BGCOL="\e[42m" || BGCOL="\e[43m"
        printf "${BGCOL}\e[30m ${BRANCH_NAME} \e[0m"
    fi
}

PS1="\[ \u\]\[\$(print_ssh_ps1)\] \[\e[44m\e[30m\] \[\w\] \[\$(print_git_branch_ps1)\]\[\e[0m\] "

rgrep()
{
    TARGET_DIR="${2}"
    if [[ -z "${TARGET_DIR}" ]]; then
        TARGET_DIR="."
    fi
    grep -irnI "${1}" "${TARGET_DIR}" --color=auto --exclude-dir={build,.git,node_modules};
}

rfind()
{
    find "$2" -name "$1";
}

setup_ssh_agent()
{
    SSH_AGENT_TIMEOUT=9000 # 2.5 hours
    ENV="${HOME}/.ssh/agent.env"

    # setup environment
    test -f "${ENV}" && . "${ENV}" >| /dev/null;

    # AGENT_RUN_STATE: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
    AGENT_RUN_STATE=$(ssh-add -l >| /dev/null 2>&1; echo ${?})

    if [ ! "${SSH_AUTH_SOCK}" ] || [ ${AGENT_RUN_STATE} = 2 ]; then
        # start agent
        (umask 077; ssh-agent >| "${ENV}")
        . "${ENV}" >| /dev/null;

        # assumes name of key is id_rsa
        ssh-add -q -t ${SSH_AGENT_TIMEOUT} >| /dev/null
    elif [ "${SSH_AUTH_SOCK}" ] && [ ${AGENT_RUN_STATE} = 1 ]; then
        ssh-add -q -t ${SSH_AGENT_TIMEOUT} >| /dev/null
    fi

    unset ${ENV}
}

# If running a git command for the first time, setup ssh-agent
g()
{
    # todo: need to only run when git would normally request a password (not on git status)
    # todo: if a new terminal window is openned (with ssh-agent process still running in the background),
    #       SSH_AGENT_PID might not be set, so the else branch here is taken when it shouldn't
    if ps -p "${SSH_AGENT_PID}" &>/dev/null
    then
        git "${@}"
    else
        setup_ssh_agent
        git "${@}"
    fi
}

open()
{
    if [[ "$OSTYPE" == "msys" ]]; then
        # NOTE: Mintty doesn't play nice with spaces in dir paths. nothing I can do..
        explorer.exe "${@////\\}" # replace slashes with backslashes (for windows)
    else
        open "${@}"
    fi
}

# Aliases
alias ls="ls -G --color=auto"
alias la="ls -a"
alias ll="ls -l"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep -iI --color=auto"
alias ebrc="vim ${HOME}/.bashrc"
alias sbrc="source ${HOME}/.bashrc > /dev/null"
alias p3="python3"
alias diff="diff -Bd -U 5 --color=auto"

