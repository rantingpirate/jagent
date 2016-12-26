#!/bin/bash

set pipefail

tmp=/tmp
agentfile="$HOME/.ssh/$(hostname)-agent"

# function checkagent() {
# 	ps -eo user,comm | grep -qe ssh-agent -e $USER
# }
#
# function checkfile() {
# 	[[ -f "$HOME/.$(hostname).agent" ]]
# }

agentd=($(find $tmp -maxdepth 1 -type d -name "ssh-*" -user $USER))
if ! [[ "$agentd" ]]; then
	ssh-agent >$agentfile
elif ! [[ -f $agentfile ]]; then
	agents="$agentd/$(ls $agentd)"
	pid=$(( ${agents##*.} + 1 ))
	echo "SSH_AUTH_SOCK=/$agents; export SSH_AUTH_SOCK;" >$agentfile
	echo "SSH_AGENT_PID=$pid; export SSH_AGENT_PID;" >>$agentfile
fi

cat $agentfile

