# Claude Code

## Project Overview

This is a dotfiles repository using NixOS flakes and Home Manager for declarative system configuration across multiple machines (anton, ben, chris, sam).

The current machine is most likely `chris`, which is the user's daily driver.

To check the system in other hosts, you can `ssh <hostname> <command>`. For example: `ssh ben "systemctl status vaultwarden"`.


## Repository Structure

### Core Infrastructure

- **flake.nix** - Nix flake configuration for declarative system management
- **hosts/** - Machine-specific NixOS configurations
- **hm/** - Home Manager configurations for user-space management
- **modules/** - Reusable Nix modules (firefox, git, go, stylix, warp)

### Application Configurations

- **configs/** - Traditional dotfiles for various applications
  - `_zshrc` - Comprehensive Zsh configuration with custom functions
  - `_tmuxp/` - Tmux session management templates
  - `_newsboat/` - RSS feed reader with curated feeds
  - `polybar/` - Linux status bar configuration
  - Various app configs (pgcli, sioyek, ripgrep, etc.)

### Custom Tools

- **dennich/** - Custom Lua-based personal tool with Neovim integration
- **python-packages/dennich/** - Personal Python package with todo management, Anki integration
- **scripts/** - Utility scripts for note-taking, tmux management, PDF processing

### Symlinked Configs (Stow)

- **stow/nvim/** - Neovim editor configuration
- **stow/awesome/** - Awesome window manager setup
- **stow/nix/** - User-specific Nix configurations
