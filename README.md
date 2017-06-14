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
