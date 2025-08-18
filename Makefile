.PHONY: rebuild-chris rebuild-sam rebuild-ben rebuild-anton install-python-tools stow stow-delete ensure-config-dirs

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
stow: ensure-config-dirs
	stow --verbose --target ~/.config/nvim --dir stow nvim
	stow --verbose --target ~/.config/awesome --dir stow awesome
	stow --verbose --target ~/.config/nix --dir stow nix

stow-delete:
	stow --delete --verbose --target ~/.config/nvim --dir stow nvim
	stow --delete --verbose --target ~/.config/awesome --dir stow awesome
	stow --delete --verbose --target ~/.config/nix --dir stow nix

# Ensure target directories exist
ensure-config-dirs:
	mkdir -p ~/.config/nvim ~/.config/awesome ~/.config/nix