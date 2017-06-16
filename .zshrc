
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="agnoster"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(git)

# User configuration
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/texbin"

# Base16 Shell
BASE16_SHELL="$HOME/.dotfiles/base16-eighties.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Aliases
alias la="ls -a"
alias ll="ls -l"
alias g="git"
alias bark="curl https://gist.githubusercontent.com/romanlarionov/d9213f1a3376a9988afd8953408d6258/raw/5d2fbd8d212a37d0a5a9b1eab531ee63341cfb16/bark.sh | bash"
