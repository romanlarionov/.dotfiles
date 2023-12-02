
function print_ssh_ps1()
{
    if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
        printf "\e[31m@%s\e[0m" "$(hostname)"
    fi
}

function print_git_branch_ps1()
{
    local BRANCH_NAME
    BRANCH_NAME="$(git branch --show-current 2> /dev/null)"

    if [[ -n "${BRANCH_NAME}" ]]; then
        local BGCOL="\e[43;30m"
        if [[ -z "$(git status 2>/dev/null | grep 'Changes not staged for commit')" ]]; then
            BGCOL="\e[42;30m"
        else
            BGCOL="\e[43;30m"
        fi

        printf "\x01${BGCOL}\x02 ${BRANCH_NAME} \x01\e[0m\x02"
    fi
}

PS1='\[\e]0;\007\]'                   # set window title
PS1="${PS1} "                         # <space>
PS1="${PS1}\u"                        # user
PS1="${PS1}\$(print_ssh_ps1)"         # bash function
PS1="${PS1} "                         # <space>
PS1="${PS1}\[\e[44;30m\]"             # begin blue background, black foreground
PS1="${PS1} "                         # <space>
PS1="${PS1}\w"                        # current working directory
PS1="${PS1} "                         # <space>
PS1="${PS1}\[\e[0m\]"                 # end blue background, black foreground
PS1="${PS1}\$(print_git_branch_ps1)"  # bash function
PS1="${PS1}\[\e[0m\]"                 # clear color
PS1="${PS1} "                         # <space>
export PS1

function rgrep()
{
    # TODO: need to change the line number format to: +<num> vs :<num>
    # this is for each vim support to jump to the correct line number after a grep
    local TARGET_DIR_REGEX
    local TARGET_DIR
    local S_DIR

    TARGET_DIR_REGEX=$(if [ -z "${2}" ]; then echo "."; else echo "${2}"; fi)
    IFS="*" read -r -a TARGET_DIR <<<"${TARGET_DIR_REGEX}"
    S_DIR=$(if [ -z "${TARGET_DIR[0]}" ]; then echo "."; else echo "${TARGET_DIR[0]}"; fi)

    # TODO: can't use 'script' as it isn't cross platform
    local GREP_OUT
    GREP_OUT="$(script -q /dev/null grep -iInr --include="*${TARGET_DIR[1]##*.}" "${1}" "${S_DIR}" \
        --color=auto --exclude-dir={build,.git,node_modules,deps,assets} | sed 's/\.\/*//')"
    echo "${GREP_OUT}"
}

function rfind()
{
    local TARGET_DIR
    TARGET_DIR="${2}"
    if [[ -z "${TARGET_DIR}" ]]; then
        TARGET_DIR="."
    fi
    find "${TARGET_DIR}" -iname "*${1}*";
}

function setup_ssh_agent()
{
    mkdir -p "${HOME}/.ssh"
    SSH_AGENT_TIMEOUT=9000 # 2.5 hours
    SSH_ENV="${HOME}/.ssh/agent.env"

    # setup environment
    test -r "${SSH_ENV}" && eval "$(<${SSH_ENV})" >/dev/null;

    AGENT_RUN_STATE=$(ssh-add -l >/dev/null 2>&1; echo ${?})

    if [ ! "${SSH_AUTH_SOCK}" ] || [ ${AGENT_RUN_STATE} = 2 ]; then
        (umask 066; ssh-agent > "${SSH_ENV}")
        eval "$(<${SSH_ENV})" >/dev/null;

        # assumes name of key is id_rsa
        ssh-add -q -t ${SSH_AGENT_TIMEOUT} >/dev/null
    elif [ ! "${SSH_AUTH_SOCK}" ] || [ ${AGENT_RUN_STATE} = 1 ]; then
        ssh-add -q -t ${SSH_AGENT_TIMEOUT} >/dev/null
    fi
}

# If running a git command for the first time, setup ssh-agent
function g()
{
    # TODO: need to only run when git would normally request a password (not on git status)
    setup_ssh_agent
    git "${@}"
}

function tag()
{
    if [[ "${OSTYPE}" == *"msys"* ]]; then
        if [[ -z $(which mintty.exe 2>/dev/null) ]]; then
            return
        fi
    fi

    local TARGET_DIR
    TARGET_DIR="${@}"
    if [[ -z "${TARGET_DIR}" ]]; then
        TARGET_DIR="."
    fi
    find "${TARGET_DIR}" -type f -iregex '.*\.\(h\|hpp\|c\|cpp\|hxx\)$' | xargs -d '\n' ctags -a
}

function ropen()
{
    if [[ "${OSTYPE}" == *"msys"* ]]; then
        # NOTE: Mintty doesn't play nice with spaces in dir paths. nothing I can do..
        explorer.exe "${@////\\}" # replace slashes with backslashes (for windows)
    else
        open "${@}"
    fi
}

if [[ "${OSTYPE}" == "darwin"* ]]; then
    LSCOLORS="Gxfxcxdxbxegedabagacad"
    export LSCOLORS
    alias ls="ls -h -G"
else
    alias ls="ls -h -G --color=auto"
fi

alias la="ls -a"
alias ll="ls -l"
alias ..="cd .."
alias ...="cd ../.."
alias wc="wc -l"

# TODO: the grep/find stuff is so complicated...
# I'm sure there's something simpler I could do
alias _grep_common="grep -iI --color=auto -d skip"
alias xgrep="xargs grep -iIr --color=auto"
#alias rgrep="ls | xargs grep -iIr --color=auto"
alias vim='vim --noplugin -u ${HOME}/.vimrc'
alias edf='cd . && cd ${HOME}/.vim/sessions && vim && cd - >/dev/null'
alias sdf='cd . && source ${HOME}/.bashrc && cd - >/dev/null'
alias diff="diff -Bd -U 5 --color=auto"

if [[ -n $(which mintty.exe 2>/dev/null) ]]; then
    alias mintty='$(mintty.exe --Border frame --exec "/usr/bin/bash" --login &)'
fi

shopt -s checkwinsize
shopt -s histappend

HISTCONTROL=ignoredups:erasedups
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
export HISTSIZE=100000
export HISTFILESIZE=${HISTSIZE}
export TERM=xterm-256color

if [[ -f "${HOME}/.bashrc.local" ]]; then
    source "${HOME}/.bashrc.local"
fi

