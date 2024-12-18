.PHONY: install-python-tools
install-python-tools:
	uv tool install apyanki
	uv tool install awscli
	uv tool install mdformat --with mdformat-gfm
	uv tool install pre-commit
	uv tool install ruff

.PHONY: stow
stow:
	stow -t ~ -d stow hyprland
	stow -t ~ -d stow nvim
	stow -t ~ -d stow awesome

.PHONY: stow-delete
stow-delete:
	stow -D -t ~ -d stow hyprland
	stow -D -t ~ -d stow nvim
	stow -D -t ~ -d stow awesome

