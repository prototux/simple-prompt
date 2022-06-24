# simple-prompt
My personal (zsh) prompt, a simple one.

Less than 3 chars by default, 2 lines max, nothing fancy.

## Features

* Git line with current repo status, branch, etc
* Last command status indication
* Root indication
* Background process indication
* Current dir
* Xdev env indication

## How to use
Simply add this to your zshrc:
```
setopt PROMPT_SUBST
source path/to/prompt.sh
```
