#!/bin/bash

set pipefail

ls=/bin/ls
tmp=/tmp
agentfile="$HOME/.ssh/$(hostname)-agent"
running=0

# List all ssh-agent directories
agentd=( $(find $tmp -maxdepth 1 -type d -name "ssh-*" -user $USER) )

# Make sure the agentfile is secure
(umask 077 && touch "$agentfile")

# Ignore zombie agent directories
for dir in "${agentd[@]}"; do
	agents="$dir/$( $ls "$dir" )"
	pid=$(( ${agents##*.} + 1 ))

	# If the agent is still running and is ours
	if [[ -d /proc/$pid ]] && [[ $(stat -c '%U' /proc/$pid) == "$USER" ]]; then
		# Fill the agentfile
		echo "SSH_AUTH_SOCK=/$agents; export SSH_AUTH_SOCK;" >"$agentfile"
		echo "SSH_AGENT_PID=$pid; export SSH_AGENT_PID;" >>"$agentfile"
		running=1
		break
	fi
done

# If there wasn't a running agent, start one.
if ! (( $running )); then
	ssh-agent >"$agentfile"
fi

cat "$agentfile"

