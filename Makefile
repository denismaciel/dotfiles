.PHONY: rebuild-chris rebuild-sam rebuild-ben rebuild-anton rebuild-zeze bootstrap install-python-tools stow stow-delete ensure-config-dirs help

# Show available commands
help:
	@echo "Available commands:"
	@echo "  bootstrap HOST=hostname  - Bootstrap new NixOS machine with experimental features"
	@echo "  rebuild-chris           - Rebuild chris configuration"
	@echo "  rebuild-sam             - Rebuild sam configuration (remote)"
	@echo "  rebuild-ben             - Rebuild ben configuration (remote)"
	@echo "  rebuild-anton           - Rebuild anton configuration (remote)"
	@echo "  rebuild-zeze            - Rebuild zeze configuration (remote - Raspberry Pi)"
	@echo "  install-python-tools    - Install Python development tools"
	@echo "  stow                   - Stow config files"
	@echo "  stow-delete            - Remove stowed config files"
	@echo ""
	@echo "Examples:"
	@echo "  make bootstrap HOST=anton"
	@echo "  make rebuild-chris"

# NixOS rebuilds
rebuild-chris:
	sudo nixos-rebuild switch --flake ~/dotfiles#chris

rebuild-sam:
	nixos-rebuild switch --flake ~/dotfiles#sam --target-host sam --sudo

rebuild-ben:
	nixos-rebuild switch --flake ~/dotfiles#ben --target-host ben --sudo

rebuild-anton:
	nixos-rebuild switch --flake ~/dotfiles#anton --target-host anton --sudo

rebuild-zeze:
	nixos-rebuild switch --flake ~/dotfiles#zeze --target-host zeze --sudo

# Bootstrap command for new machines
# Usage: make bootstrap HOST=hostname
bootstrap:
	@if [ -z "$(HOST)" ]; then \
		echo "Error: HOST parameter is required"; \
		echo "Usage: make bootstrap HOST=hostname"; \
		echo "Example: make bootstrap HOST=anton"; \
		exit 1; \
	fi
	@echo "Bootstrapping NixOS configuration for host: $(HOST)"
	@echo "Enabling experimental features temporarily..."
	@export NIX_CONFIG="experimental-features = nix-command flakes" && \
	export NIXPKGS_ALLOW_UNFREE=1 && \
	nix build .#nixosConfigurations.$(HOST).config.system.build.toplevel
	@echo "Configuration built successfully! Applying to system..."
	@export NIX_CONFIG="experimental-features = nix-command flakes" && \
	export NIXPKGS_ALLOW_UNFREE=1 && \
	sudo nixos-rebuild switch --flake .#$(HOST)
	@echo "🎉 Bootstrap complete! Experimental features are now permanently configured."
	@echo "Future rebuilds can use: make rebuild-$(HOST)"

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

stow-delete:
	stow --delete --verbose --target ~/.config/nvim --dir stow nvim
	stow --delete --verbose --target ~/.config/awesome --dir stow awesome

# Ensure target directories exist
ensure-config-dirs:
	mkdir -p ~/.config/nvim ~/.config/awesome