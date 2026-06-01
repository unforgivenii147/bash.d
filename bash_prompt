COLOR_RESET='\[\033[0m\]'
BG1_DARK_GRAY='48;2;50;50;50'
FG1_YELLOW='38;2;25l15;240;45'
FG2_CYAN_BLUE='38;2;0;135;175'
BG2_CYAN_BLUE='48;2;0;135;175'
FG3_WHITE='38;2;255;255;255'
ARROW_BG1='38;2;50;50;50'
ARROW_BG2='38;2;0;135;175'
__git_ps1_info() {
	local branch_info
	branch_info=$(git symbolic-ref --short HEAD 2>/dev/null)
	if [ -n "$branch_info" ]; then
		local status=""
		git diff --quiet --ignore-submodules --cached || status=""
		git diff --quiet --ignore-submodules || status="*"
		echo "(${branch_info}${status})"
	fi
}
__custom_ps1_builder() {
	local PS1_STRING=""
	local GIT_INFO=$(__git_ps1_info)
	local VENV_NAME=""
	if [ -n "$VIRTUAL_ENV" ]; then
		VENV_NAME="($(basename "$VIRTUAL_ENV"))"
	fi
	if [ -n "$VENV_NAME" ] || [ -n "$GIT_INFO" ]; then
		PS1_STRING+="\[\033[${BG1_DARK_GRAY};${FG2_CYAN_BLUE}m\]"
		if [ -n "$VENV_NAME" ]; then
			PS1_STRING+=" $VENV_NAME "
		fi
		if [ -n "$GIT_INFO" ]; then
			if [ -n "$VENV_NAME" ]; then
				PS1_STRING+="\[\033[${BG1_DARK_GRAY};${FG1_YELLOW}m\] | "
			fi
			PS1_STRING+=" $GIT_INFO "
		fi
		PS1_STRING+="\[\033[${ARROW_BG2}m\]"
	fi
	PS1_STRING+="\[\033[${BG2_CYAN_BLUE};${FG3_WHITE}m\]"
	PS1_STRING+=" \W "
	PS1_STRING+="\[\033[49;${ARROW_BG2}m\]"
	PS1_STRING+="${COLOR_RESET} \$ "
	echo "$PS1_STRING"
}
PROMPT_COMMAND='PS1=$(__custom_ps1_builder)'
