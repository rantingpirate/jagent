#!/bin/bash

set pipefail

# Use bare executables for predictable behaviour
ls=/bin/ls
find=/bin/find

tmp=/tmp
running=0

# List all ssh-agent directories
agentd=( $($find $tmp -maxdepth 1 -type d -name "ssh-*" -user $USER) )

# Ignore zombie agent directories
for dir in "${agentd[@]}"; do
	agents="$dir/$( $ls "$dir" )"
	pid=$(( ${agents##*.} + 1 ))

	# If the agent is still running and is ours
	procdir="/proc/$pid"
	if [[ -d "$procdir" ]] \
		&& [[ $(stat -c '%U' "$procdir") == "$USER" ]] \
		&& [[ $(cat "$procdir/comm") == "ssh-agent" ]]
	then
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
