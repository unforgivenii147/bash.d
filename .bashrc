export PREFIX="/data/data/com.termux/files/usr"
export HOME="/data/data/com.termux/files/home"
export TERMUX_PREFIX="$PREFIX"
export CARGO_BUILD_JOBS=8
export EDITOR='nvim'
export VISUAL='nvim'
export DISPLAY=:0
export MOZ_HEADLESS=1
export TESSDATA_PREFIX="$HOME/.local/share/tessdata_best"
export JDK_HOME="$PREFIX/lib/jvm/java-26-openjdk"
export JAVA_HOME="$PREFIX/lib/jvm/java-26-openjdk"
export CMAKE_INSTALL_PREFIX="$HOME/.local"
export CMAKE_BUILD_TYPE=RELEASE
export CMAKE_BUILD_PARALLEL_LEVEL=4
export CMAKE_POLICY_VERSION_MINIMUM="3.5.0"
export PYTHONHASHSEED="random"
export PYTHON_HISTORY="$HOME/.local/var/python_history"
export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages:$PREFIX/lib/python3.14/site-packages"
export LD_LIBRARY_PATH="$PREFIX/lib:$HOME/.local/lib"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$HOME/.local/lib/pkgconfig"
export PAGER="less"
export FORCE_COLOR=1
export TERM=xterm-256color
export RUFF_CACHE_DIR="$HOME/.cache/ruff"
export RUFF_CONFIG_FILE="$HOME/.config/ruff/ruff.toml"
export MANPATH="$PREFIX/share/man:$HOME/.local/share/man"
export APACHE_LOG_DIR="$HOME/tmp/log/apps"
export CFLAGS="-fPIC -O3"
export ARCHIVE_DOWNLOAD_DIR="/sdcard/backups"
export PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True
export SODIUM_INSTALL_MINIMAL=1
export USE_SYSTEM_LIB=1
export USE_SYSTEM_LIBS=1
PATH_DIRS=(
	"$HOME/.local/bin"
	"$HOME/bin"
	"$HOME/bashbin"
	"$HOME/.cargo/bin"
	"$HOME/.npm-global/bin"
	"$PREFIX/bin"
	"$HOME/.local/share/nvim/mason/bin"
)
NEW_PATH=""
for dir in "${PATH_DIRS[@]}"; do
	if [ -d "$dir" ] && [[ ":$NEW_PATH:" != *":$dir:"* ]]; then
		NEW_PATH="${NEW_PATH:+$NEW_PATH:}$dir"
	fi
done
export PATH="$NEW_PATH"
venv_prompt() {
	if [ -n "$VIRTUAL_ENV" ]; then
		echo "($(basename "$VIRTUAL_ENV")) "
	fi
}
precmd() {
	printf '\e[5 q' # underline cursor (blinking)
}
shopt -s autocd cdspell checkwinsize cmdhist dirspell dotglob globstar histappend 2>/dev/null
HISTCONTROL=ignoredups:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
GOK="\[\e[38;2;80;250;118m\]"
AK="\[\e[38;2;185;52;49m\]"
KARA="\[\e[38;2;220;160;68m\]"
RESET="\[\e[0m\]"
PS1="\$(venv_prompt)${AK}[${GOK}\W${AK}]${KARA} \$ ${RESET}"
PROMPT_COMMAND="precmd"
for conf in "$HOME/.config/bash.d/"{aliases,functions,apps}.sh; do
	[ -f "$conf" ] && . "$conf"
done
if [ -f "$PREFIX/etc/bash_completion" ] && ! shopt -oq posix; then
	. "$PREFIX/etc/bash_completion"
fi
if [[ -f ~/.bash_secrets ]] && [[ -r ~/.bash_secrets ]]; then
	source ~/.bash_secrets
fi
[ -f ~/.ls_colors ] && . ~/.ls_colors
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
mkdir -p "$APACHE_LOG_DIR"
if [[ $- == *i* ]] && [ -z "$UNDER_SCRIPT" ]; then
	LOG_DIR="$HOME/tmp/log"
	mkdir -p "$LOG_DIR"
	LOG_FILE="$LOG_DIR/$(LC_TIME=C date +%a%d%b%H%M | tr '[:lower:]' '[:upper:]').log"
	export UNDER_SCRIPT=1
	exec script -q -f "$LOG_FILE"
fi
source ~/.ls_colors
export CPPFLAGS="-I$HOME/.local/include -I$PREFIX/include"
export LDFLAGS="-L$HOME/.local/lib -L$PREFIX/lib"
export CFLAGS="$CPPFLAGS"
export CXXFLAGS="$CPPFLAGS"
export LIBRARY_PATH="$HOME/.local/lib:$PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:$PREFIX/lib:$LD_LIBRARY_PATH"
export RUSTFLAGS="-L$HOME/.local/lib -L$PREFIX/lib"
#export PYTHONDONTWRITEBYTECODE=1
#export PYTHONPYCACHEPREFIX="/noexist"
export ENABLE_CONTRIB=1
export Py_ENABLE_SHARED=1
export NVIM_LOG_FILE="$HOME/tmp/log/apps/nvim.log"
#export PYMUPDF_USE_SYSTEM_MUPDF=1
#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
jcal
random_quote
