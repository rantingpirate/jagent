#!/bin/bash

set pipefail

ls=/bin/ls
find=/bin/find
tmp=/tmp

# List all ssh-agent directories
agentd=( $($find $tmp -maxdepth 1 -type d -name "ssh-*" -user $USER) )

for dir in "${agentd[@]}"; do
	agents="$dir/$( $ls "$dir" )"
	pid=$(( ${agents##*.} + 1 ))
	if ! [[ -d "/proc/$pid" ]]; then
		rm -vr "$dir"
	fi
done
