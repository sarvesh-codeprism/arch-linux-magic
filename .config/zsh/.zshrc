export ZSH="$HOME/.config/zsh/oh-my-zsh"
ZSH_THEME="alanpeabody"
HISTFILE=~/.cache/zsh/history
plugins=(git zsh-autosuggestions nvm)
source $ZSH/oh-my-zsh.sh
source "$XDG_CONFIG_HOME/shell/aliasrc"
