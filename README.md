# silhouette

## a silhouette for your user profile

Use configuration management (Ansible) to describe your user profile(s).

## Dependencies
- python
- ansible

### bootstrap
#### OS X
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install python ansible
git clone git@github.com:hypertactics/silhouette.git $HOME/.silhouette
```

### The goals
- manage dotfiles via YAML (Ansible solves this out the door) which generates static dotfiles in a more custom way (per platform and maybe location someday)
- install development tools with configuration management instead of custom shell scripts.
