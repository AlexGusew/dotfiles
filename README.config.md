Based on [this tutorial](https://www.atlassian.com/git/tutorials/dotfiles)

### How to use

It's bare git repository, and has alias `config` to `git --git-dir=$HOME/.cfg/`, so `config` is just `git` CLI.

Configuration stored inside of `~/.cfg`.

This repo includes NVIM configs as git submodule, stored in `~/.config/nvim`.

### Installation

```sh
git clone --bare --recurse-submodules git@github.com:AlexGusew/dotfiles.git $HOME/.cfg
```

Cheers!
