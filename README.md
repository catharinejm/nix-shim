### Installation

* Install [nix-shell](https://nixos.org/nix/manual/#chap-installation)
```zsh
bash <(curl https://nixos.org/nix/install)
```
* Clone the repo
```zsh
git clone https://github.com/jondistad/nix-shim ~/.nix-shim
```
* Add the following your zshrc
```zsh
export NIX_SHIM_ROOT="$HOME/.nix-shim"
export PATH="$NIX_SHIM_ROOT/bin:$PATH"
```
* Start adding shims!
```zsh
nix-shim --help # print usage
```

### ZSH

I use zsh, so all these scripts use zsh-specific features. I have no
idea if they work in bash. However, you could just install zsh even if
you don't want to use it, and let the scripts run it. I expect that'll work.

### Example

```zsh
$ nix-shim add -p scala scala scalac

Adding 2 commands to package scala:

  scala
  scalac

$ which scala scalac
/home/jon/.nix-shim/bin/scala
/home/jon/.nix-shim/bin/scalac
$ scala -version
Scala code runner version 2.12.1 -- Copyright 2002-2016, LAMP/EPFL and Lightbend, Inc.
$ scalac -version
Scala compiler version 2.12.1 -- Copyright 2002-2016, LAMP/EPFL and Lightbend, Inc.
```
