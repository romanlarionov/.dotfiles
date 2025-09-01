.dotfiles
========

These are all of my personal configurations for my various work stations.

Installation
========

```shell
git clone git@github.com:romanlarionov/.dotfiles.git && cd .dotfiles && ./install.sh
```

The above installer will save any aliased dotfiles (listed in `.files`) already found in the home directory into ~/.dotfiles/OldDotFiles/<num>_last.

Check for Differences
========
```shell
./check_diff.sh
```

Uninstallation
========

From within the .dotfiles directory:

```shell
./uninstall.sh
```
