
export ZSH=${HOME}/.oh-my-zsh
ZSH_THEME="agnoster"
COMPLETION_WAITING_DOTS="true"
plugins=(git)

source ${ZSH}/oh-my-zsh.sh

# Terminal colors
BASE16_SHELL="${HOME}/.dotfiles/base16-eighties.dark.sh"
[[ -s ${BASE16_SHELL} ]] && source ${BASE16_SHELL}

function rgrep { grep -rn "$1" "$2" --color; }
function rfind { find "$2" -name "$1"; }

# todo: this is only on mac for now
function rperf {
    start_ms=$(ruby -e 'puts (Time.now.to_f * 1000).to_i');
    $($@);
    end_ms=$(ruby -e 'puts (Time.now.to_f * 1000).to_i');
    elapsed_ms=$((end_ms - start_ms));
    echo "";
    echo "perf output: $elapsed_ms ms passed";
}

function mergecheck {
    git format-patch $(git merge-base "$1" "$2").."$2" --stdout | git apply --check -;
}

alias grep="grep -n --color"
alias ls="ls -G"
alias la="ls -a"
alias ll="ls -l"
alias g="git"
alias p3="python3"
alias ezrc="vim ~/.zshrc"
alias szrc="source ~/.zshrc"
alias bark="curl https://gist.githubusercontent.com/romanlarionov/d9213f1a3376a9988afd8953408d6258/raw/5d2fbd8d212a37d0a5a9b1eab531ee63341cfb16/bark.sh | bash"

source ${HOME}/.zshrc.local
