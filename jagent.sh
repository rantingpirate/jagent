#!/bin/bash

tmp=/tmp
agentfile="$HOME/.ssh/$(hostname)-agent"

chkagent="find $tmp -maxdepth 1 -type d -name 'ssh-*' -user $USER -print0 | grep -qz ."

# function checkagent() {
# 	ps -eo user,comm | grep -qe ssh-agent -e $USER
# }
#
# function checkfile() {
# 	[[ -f "$HOME/.$(hostname).agent" ]]
# }

if ! $chkagent; then
	ssh-agent >$agentfile
elif ! [[ -f $agentfile ]]; then
	agentd=($(find $tmp -maxdepth 1 -type d -name "ssh-*" -user $USER))
	agents="$agentd/$(ls $agentd)"
	pid=$(( ${agents##*.} + 1 ))
	echo "SSH_AUTH_SOCK=/$agents; export SSH_AUTH_SOCK;" >$agentfile
	echo "SSH_AGENT_PID=$pid; export SSH_AGENT_PID;" >>$agentfile
fi

cat $agentfile

