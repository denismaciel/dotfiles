.PHONY: rebuild-chris rebuild-sam rebuild-ben rebuild-anton install-python-tools stow stow-delete

# NixOS rebuilds
rebuild-chris:
	sudo nixos-rebuild switch --flake ~/dotfiles#chris

rebuild-sam:
	nixos-rebuild switch --flake ~/dotfiles#sam --target-host sam --sudo

rebuild-ben:
	nixos-rebuild switch --flake ~/dotfiles#ben --target-host ben --sudo

rebuild-anton:
	nixos-rebuild switch --flake ~/dotfiles#anton --target-host anton --sudo

# Python tools installation
install-python-tools:
	uv tool install --upgrade apyanki
	uv tool install --upgrade awscli
	uv tool install --upgrade mdformat --with mdformat-gfm
	uv tool install --upgrade pre-commit
	uv tool install --upgrade ruff

# Stow operations
stow:
	stow -t ~ -d stow nvim
	stow -t ~ -d stow awesome
	stow -t ~ -d stow nix
	stow -t ~ -d stow ghostty

stow-delete:
	stow -D -t ~ -d stow nvim
	stow -D -t ~ -d stow awesome
	stow -D -t ~ -d stow nix
	stow -D -t ~ -d stow ghostty