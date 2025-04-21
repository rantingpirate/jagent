A simple script to manage using a single ssh agent over any number of 
terminal sessions. There's other scripts that do this, but this one is 
specifically short and simple to make it easy to see all the nefarious 
things it doesn't do.

# Usage
Just add `eval $(path/to/jagent.sh)` to your `.bashrc` or equivalent.
If you want to be a bit fancier / more portable, you can check whether
it exists first:
```bash
if [[ -f "path/to/jagent.sh" ]]; then
    eval $(path/to/jagent.sh)
fi
```

# agent-clean
Currently, jagent does NOT automatically clean unused ssh-agents, as 
that's the operating system's job. If your OS isn't doing that
(e.g. Ubuntu on WSL), [`agent-clean.sh`] will remove all agents
with a pid that doesn't match a running process.