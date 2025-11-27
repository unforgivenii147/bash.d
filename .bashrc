shopt -s globstar
shopt -s dotglob

source ~/.bash.d/.ba
source ~/.bash.d/.bf
source ~/.bash.d/.bf2

export PATH=$HOME/bin:$PATH
export EDITOR='nano'
export VISUAL='nano'
export PYTHONNOBYTECOMPILE=1


### ====== ENVIRONMENT ====== ###

export PATH="$HOME/.local/bin:$PATH"

export CC=clang
export CXX=clang++
export PYTHONSTARTUP=""

venv_prompt() {
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "($(basename $VIRTUAL_ENV)) "
    fi
}


HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s checkwinsize
shopt -s globstar
if [ -f /data/data/com.termux/files/usr/etc/bash_completion ] && ! shopt -oq posix; then
. /data/data/com.termux/files/usr/etc/bash_completion
fi


#PS1='\[\033[48;2;221;75;57;38;2;255;255;255m\] \$ \[\033[48;2;0;135;175;38;2;221;75;57m\]\[\033[48;2;0;135;175;38;2;255;255;255m\] \w \[\033[49;38;2;83;85;85m\]\[\033[00m\] '
#PS1='\[\033[48;2;0;135;175;38;2;105;121;16m\]\[\033[48;2;0;135;175;38;2;255;255;255m\] \w 
export PS1='\[\033[48;2;83;85;85;38;2;0;135;175m\]\[\033[48;2;83;85;85;38;2;255;255;255m\] \w \[\033[49;38;2;83;85;85m\]\[\033[00m\] '
#export PS1='\[$(venv_prompt)\]\W\$ '

cd ~/isaac/dec
clear

