
if [[ -f ~/.bashrc.local ]]; then
    source ~/.bashrc.local
fi

# set up ssh-agent on first git push/pull (if on windows?)

BASE16_SHELL="${HOME}/.dotfiles/base16-eighties.dark.sh"
[[ -s ${BASE16_SHELL} ]] && source ${BASE16_SHELL}

function rgrep { grep -irn "$1" "$2" --color; }
function rfind { find "$2" -name "$1"; }

alias ls="ls -G --color"
alias la="ls -a"
alias ll="ls -l"
alias ..="cd .."
alias ...="cd ..."
alias g="git"
alias grep="grep -irn --color"
alias ebrc="vim ~/.bashrc"
alias sbrc="source ~/.bashrc > /dev/null"
alias p3="python3"

if [[ "$OSTYPE" == "msys" ]]; then
    alias open="explorer "
fi

