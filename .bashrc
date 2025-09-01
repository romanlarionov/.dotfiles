
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

function new_line()
{
    printf "\n "
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
PS1="${PS1}$(new_line)"               # <space>
PS1="${PS1}"                          # <space>
export PS1

SSH_AGENT_DIR="$HOME/.ssh-agent"
mkdir -p "$SSH_AGENT_DIR"
SSH_AGENT_FILE="$SSH_AGENT_DIR/agent.env"
SSH_AGENT_TIMEOUT=7200 # Timeout in seconds

# Load existing agent if available and not expired
if [ -f "$SSH_AGENT_FILE" ]; then
    source "$SSH_AGENT_FILE"
    # Check if agent is alive and not expired
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null || \
       [ $(( $(date +%s) - $SSH_AGENT_START )) -ge $SSH_AGENT_TIMEOUT ]; then
        # Expired or dead, remove file
        rm -f "$SSH_AGENT_FILE"
        unset SSH_AGENT_PID SSH_AUTH_SOCK SSH_AGENT_START
    fi
fi

start_ssh_agent()
{
    if [ -z "$SSH_AGENT_PID" ]; then
        echo "Starting SSH agent..."
        eval "$(ssh-agent -s)"
        export SSH_AGENT_START=$(date +%s)

        # Add signing key
        if [ -f "$HOME/.ssh/github" ]; then
            ssh-add "$HOME/.ssh/github"
        fi

        # Add auth key
        if [ -f "$HOME/.ssh/github.old" ]; then
            ssh-add "$HOME/.ssh/github.old"
        fi

        # Save environment for other terminals
        echo "export SSH_AGENT_PID=$SSH_AGENT_PID" > "$SSH_AGENT_FILE"
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> "$SSH_AGENT_FILE"
        echo "export SSH_AGENT_START=$SSH_AGENT_START" >> "$SSH_AGENT_FILE"
    fi
}

# Override git to lazy-start agent for important commands
git()
{
    local important_cmds="commit cm push ps pull pl fetch rebase merge"

    local cmd="$1"
    shift

    if [[ " $important_cmds " =~ " $cmd " ]]; then
        start_ssh_agent
    fi

    command git "$cmd" "$@"
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
        TARGET_DIR="$(pwd)"
    fi

    PROJECT_NAME="${TARGET_DIR//\\//}"
    PROJECT_NAME=$(basename "$PROJECT_NAME")

    find "${TARGET_DIR}" -type f -iregex '.*\.\(h\|hpp\|c\|cpp\|hxx\)$' | \
        xargs -d '\n' ctags -a && mv tags ${PROJECT_NAME}.tags && mv ${PROJECT_NAME}.tags ~/.tags
    echo "Updated tags: ~/.tags/${PROJECT_NAME}.tags"
}

function rfind()
{
    local TARGET_DIR
    TARGET_DIR="."
    if [[ -n "${2}" ]]; then
        TARGET_DIR="${2}"
    fi
    find "${TARGET_DIR}" -iname "*${1}*" | sed 's/\.\///' | rg -N "${1}"
}

function ropen()
{
    local FILE_PATH
    FILE_PATH="${@////\\}"
    if [[ -z ${FILE_PATH} ]]; then
        FILE_PATH="$(pwd)"
        FILE_PATH="${FILE_PATH////\\}"
    fi

    if [[ "${OSTYPE}" == *"msys"* ]]; then
        # Replace slashes with backslashes.
        # If the argument starts with "/c/" or "\c\", replace with "C:\".
        explorer.exe $(echo ${FILE_PATH} | sed 's/\/c\//C:\\/' | sed 's/\\c\\/C:\\/')
    else
        open "${@}"
    fi
}

function goog()
{
    if [[ "${OSTYPE}" == *"msys"* ]]; then
        start "https://www.google.com/search?q=$(echo ${@} | sed 's/ /+/g')"
    else
        echo "TODO: fix me"
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
alias rg="rg -in --trim"
alias g="git"
alias vim='vim -u ${HOME}/.vimrc'
alias edf='cd . && cd ${HOME}/.vim/sessions && vim && cd - >/dev/null'
alias sdf='cd . && source ${HOME}/.bashrc && cd - >/dev/null'
alias cddf='cd ${HOME}/.dotfiles'
alias diff="diff -Bd -U 5 --color=auto"
alias todo="vim ~/.todo"
alias github_ssh_keygen="ssh-keygen -t ed25519 -C "romanylarionov@gmail.com" -f ~/.ssh/github"

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

