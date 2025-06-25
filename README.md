## Manual steps still necessary to set up NixOS.

```sh
gh-clone git@github.com:recap-technologies/core.git
```

## Remote deployment

Deploy to another machine without git push/pull:

```bash
nixos-rebuild switch --flake ~/dotfiles#<host> --target-host <hostname> --use-remote-sudo
```

Example:
```bash
nixos-rebuild switch --flake ~/dotfiles#ben --target-host ben --use-remote-sudo
```
