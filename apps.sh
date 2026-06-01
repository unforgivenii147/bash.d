# ---- cargo --------

export CARGO_HOME="$HOME/.cargo"
export CARGO_INSTALL_ROOT="$HOME/.cargo"

. "$CARGO_HOME/env" 2>/dev/null

# ---- zoxide --------

export _ZO_ECHO=1
if [[ $IS_INTERACTIVE -eq 0 ]]; then
    return
fi

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash 2>/dev/null)"
fi

# direnv

if [[ $IS_INTERACTIVE -eq 0 ]]; then
    return
fi

if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash 2>/dev/null)"
fi


# fzf

export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/fzfrc"

if [[ $IS_INTERACTIVE -eq 0 ]]; then
    return
fi

if command -v fzf &>/dev/null; then
    if fzf --bash &>/dev/null; then
        eval "$(fzf --bash)"
    elif [[ -f $PREFIX/share/doc/fzf/examples/key-bindings.bash ]]; then
        source $PREFIX/share/doc/fzf/examples/key-bindings.bash
    fi
fi



export JQ_COLORS='0;33:0;33:0;33:0;33:0;32:0;39:0;39'



export IPYTHONDIR="$HOME/.config/jupyter"
export JUPYTER_CONFIG_DIR="$HOME/.config/jupyter"

#export LESS=R
export LESSHISTSIZE=1000000
export LESSOPEN='| pygmentize -O style=one-dark %s 2>/dev/null'



export MANPAGER='nvim +Man!'


export MANPATH="$PREFIX/share/man:$HOME/.local/share/man"

export NODE_REPL_HISTORY=$HOME/.local/stat/node_repl_history
export NPM_CONFIG_USERCONFIG="$HOME/.config/npmrc"

export VIRTUAL_ENV_DISABLE_PROMPT=1

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
