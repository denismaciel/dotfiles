.PHONY: rebuild-chris rebuild-sam rebuild-ben rebuild-anton install-python-tools stow stow-delete stow-conf stow-conf-delete migrate-to-stow-conf ensure-config-dirs

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

# New stow-conf operations (cleaner structure)
stow-conf: ensure-config-dirs
	stow --verbose --target ~/.config/nvim --dir stow-conf nvim
	stow --verbose --target ~/.config/awesome --dir stow-conf awesome
	stow --verbose --target ~/.config/nix --dir stow-conf nix

stow-conf-delete:
	stow --delete --verbose --target ~/.config/nvim --dir stow-conf nvim
	stow --delete --verbose --target ~/.config/awesome --dir stow-conf awesome
	stow --delete --verbose --target ~/.config/nix --dir stow-conf nix

# Migration helper
migrate-to-stow-conf:
	mkdir -p stow-conf
	cp -r stow/nvim/.config/nvim stow-conf/nvim
	cp -r stow/awesome/.config/awesome stow-conf/awesome
	cp -r stow/nix/.config/nix stow-conf/nix

# Ensure target directories exist
ensure-config-dirs:
	mkdir -p ~/.config/nvim ~/.config/awesome ~/.config/nix