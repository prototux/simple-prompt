# Utilities
PBLUE="%{%F{blue}%}"
PGREEN="%{%F{green}%}"
PRED="%{%F{red}%}"
PWHITE="%{%F{white}%}"
PYELLOW="%{%F{yellow}%}"
PCYAN="%{%F{cyan}%}"
PSEP="$PWHITE/"
PEND="%{%f%}"
PNL="%{\n%}"

# Informations to fetch before prompt
precmd() {
	# Get return code
	lret=$?
}

# Git informations, printed only in a git repo
git_prompt() {
	if [[ -n $(git rev-parse HEAD 2> /dev/null) ]]; then
		local current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
		local local_prompt="$PGREEN"
		local commit_prompt="$PWHITE"
		local remote_prompt="$PBLUE"

		# Getting more infos if the repo have log
		if [[ $(git log --pretty=oneline -n1 2> /dev/null | wc -l) -ne 0 ]]; then
			local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
			local git_status="$(git status --porcelain 2> /dev/null)"
			local tag=$(git describe --exact-match --tags $current_commit_hash 2> /dev/null)

			[[ $git_status =~ ($'\n'|^).M ]] && local_prompt+=" ◐"
			[[ $git_status =~ ($'\n'|^)M ]] && local_prompt+=" ●"
			[[ $git_status =~ ($'\n'|^)A ]] && local_prompt+=" ➕"
			[[ $git_status =~ ($'\n'|^).D ]] && local_prompt+=" ➖"
			[[ $git_status =~ ($'\n'|^)D ]] && local_prompt+=" "
			[[ $git_status =~ ($'\n'|^)[MAD] && ! $git_status =~ ($'\n'|^).[MAD\?] ]] && local_prompt+=" "
			[[ $(\grep -c "^??" <<< "${git_status}") -gt 0 ]] && local_prompt+=" ■"
			[[ $(git stash list -n1 2> /dev/null | wc -l) -gt 0 ]] && local_prompt+=" ✭"

			if [[ -n "$upstream" ]]; then
				local commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_commit_hash}...${upstream} 2> /dev/null)"
				local commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
				local commits_behind=$(\grep -c "^>" <<< "$commits_diff")
			fi
			[[ $local_prompt != $PGREEN ]] && local_prompt+=" $PSEP "
		fi

		# Commits part
		[[ -z $upstream ]] && commit_prompt="-- ●  --"
		[[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]] && commit_prompt="-${commits_behind} ◆ +${commits_ahead}"
		[[ $commits_ahead -eq 0 && $commits_behind -gt 0 ]] && commit_prompt="-${commits_behind} ▼ --"
		[[ $commits_ahead -gt 0 && $commits_behind -eq 0 ]] && commit_prompt="-- ▲ +${commits_ahead}"
		[[ $commit_prompt != $PWHITE ]] && commit_prompt+=" $PSEP "

		# Branch/Upstream part
		if [[ $current_branch == "HEAD" ]]; then
			branch=$(git rev-parse HEAD 2> /dev/null)
			remote_prompt="$PRED  (${branch:0:7})"
		elif [[ -z "$upstream" ]]; then
			remote_prompt+="$current_branch"
		else
			[[ $(git config --get branch.${current_branch}.rebase 2> /dev/null) == true ]] && symbol="◀" || symbol="◆"
			remote_prompt+="${current_branch} ${symbol} ${upstream//\/$current_branch/}"
		fi
		[[ -n $tag ]] && remote_prompt+="■$tag"

		# Print the git prompt
		echo "%{${local_prompt}${commit_prompt}${remote_prompt}${PEND}${PNL}%}"
	fi
}

prompt_end() {
	rcolor="${PWHITE}"
	[[ $lret -ne 0 && $lret -ne 148 ]] && rcolor="${PRED}"
	echo "${rcolor}»${PEND} "
}

# Build the prompt
PROMPT='%{%f%b%k%}' # Start of prompt
PROMPT+='$(git_prompt)' # Git prompt if needed
[[ $(jobs -l | wc -l) -gt 0 ]] && PROMPT+="${PYELLOW}●${PWHITE}" # Background jobs
[[ $UID -eq 0 ]] && PROMPT+="${PYELLOW}⚡${PWHITE}" # Root shell
PROMPT+=" ${PBLUE}%~ " # Current dir
[[ ! -z $XDEV ]] && PROMPT+="${PCYAN}[$XDEV]" # Dev env
PROMPT+='$(prompt_end)' # Prompt end symbol (color for last status)
