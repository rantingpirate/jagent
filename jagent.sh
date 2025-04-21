#!/bin/bash

set pipefail

tmp=${TMPDIR:-/tmp}
if [[ "$(uname)" == Darwin ]] && [[ -z "$TMPDIR" ]]; then
	gctmp="$(getconf DARWIN_USER_TEMP_DIR)"
	tmp="${gctmp:-/tmp}"
fi

running=0

# List all ssh-agent directories
agentd=( $(find $tmp -maxdepth 1 -type d -name "ssh-*" -user $USER) )

# Ignore zombie agent directories
for dir in "${agentd[@]}"; do
	agents="$(find $dir -name 'agent.*' -print -quit)"
	if [[ "$agents" == "" ]]; then continue; fi
	pid=$(( ${agents##*.} + 1 ))

	# If the agent is still running and is ours
	if ps -axo pid,uid,comm | grep -q "^ *$pid  *$UID .*ssh-agent"; then
		# Export the variables
		echo "SSH_AUTH_SOCK=$agents; export SSH_AUTH_SOCK;"
		echo "SSH_AGENT_PID=$pid; export SSH_AGENT_PID;"
		echo "echo Agent pid $pid"
		running=1
		break
	fi
done

# If there wasn't a running agent, start one.
if ! (( $running )); then
	ssh-agent
fi
