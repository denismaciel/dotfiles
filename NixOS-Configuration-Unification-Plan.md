# NixOS Configuration Unification & Improvement Plan

## Overview

This document outlines a comprehensive plan to unify and improve the NixOS configurations across all hosts (chris, anton, ben, sam). Chris is the primary personal machine while the others serve as servers, allowing us to streamline server configurations significantly.

## Current State Analysis

### Host Configurations

| Feature              | chris      | anton    | ben                  | sam             |
| -------------------- | ---------- | -------- | -------------------- | --------------- |
| **Role**             | Personal   | Server   | Server               | Print Server    |
| **Desktop**          | Awesome WM | GNOME    | Awesome WM           | GNOME           |
| **System Version**   | 23.11      | 24.05    | 23.11                | 24.05           |
| **Special Services** | None       | None     | Vaultwarden, AdGuard | Printer sharing |
| **Tailscale Mode**   | Client     | Basic    | Exit Node            | Basic           |
| **Firewall**         | Selective  | Disabled | Enabled              | Enabled         |

### Key Issues Identified

1. **Inconsistent System Versions**: Mixed 23.11 and 24.05 versions
1. **Duplicated Configuration**: Common settings scattered across files
1. **Desktop Environment Bloat**: Servers running unnecessary GUI components
1. **Security Inconsistencies**: Mixed firewall and SSH configurations
1. **Package Redundancy**: Similar packages installed differently across hosts
1. **Home Manager Inconsistency**: Different module structures and imports

## Unification Strategy

### Phase 1: Create Base Modules (Low Risk)

#### 1.1 Create Core Base Module (`modules/base.nix`)

```nix
# Common system-wide configuration for all hosts
{
  nix.settings = {
    trusted-users = ["denis"];
    auto-optimise-store = true;
  };
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  # Standard user configuration
  users.users.denis = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFJLQFWmH33Gmo2pGMtaQ0gPfAuqMZwodMUvDJwFTMy denispmaciel@gmail.com"
    ];
  };
  
  # Common system packages
  environment.systemPackages = with pkgs; [
    git
    neovim
  ];
  
  programs.zsh.enable = true;
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
```

#### 1.2 Create Server Base Module (`modules/server-base.nix`)

```nix
# Server-specific base configuration
{
  # Disable sleep/suspend for servers
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  
  # Basic server networking
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  
  # Basic security
  networking.firewall.enable = true;
  services.openssh.ports = [22 443 2222 7422];
  services.openssh.settings.PasswordAuthentication = false;
}
```

#### 1.3 Create Desktop Base Module (`modules/desktop-base.nix`)

```nix
# Desktop-specific base configuration
{
  # Desktop services
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  services.printing.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  
  # Desktop user groups
  users.users.denis.extraGroups = [
    "networkmanager" "wheel" "docker" "audio"
  ];
  
  virtualisation.docker.enable = true;
}
```

### Phase 2: Standardize Host Configurations (Medium Risk)

#### 2.1 Simplify Server Configurations

**For anton (Basic Server):**

```nix
# Minimal server configuration
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/server-base.nix
    ../../modules/unfree.nix
  ];
  
  networking.hostName = "anton";
  time.timeZone = "Europe/Lisbon";
  system.stateVersion = "24.05";
}
```

**For sam (Print Server):**

```nix
# Print server configuration
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/server-base.nix
    ../../modules/unfree.nix
    ../../modules/printing.nix  # New module
  ];
  
  networking.hostName = "sam";
  time.timeZone = "Europe/Lisbon";
  system.stateVersion = "24.05";
}
```

**For ben (Exit Node + Services):**

```nix
# Service server configuration
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/server-base.nix
    ../../modules/unfree.nix
    ../../modules/vaultwarden-backup.nix
    ../../modules/adguard.nix  # New module
  ];
  
  networking.hostName = "nixos-ben";
  time.timeZone = "Europe/Lisbon";
  system.stateVersion = "23.11";
  
  # Tailscale exit node
  services.tailscale.extraUpFlags = ["--accept-dns" "--advertise-exit-node"];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
}
```

#### 2.2 Streamline Chris Configuration

```nix
# Personal desktop configuration
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop-base.nix
    ../../modules/chris-desktop.nix  # Chris-specific desktop config
    ../../modules/unfree.nix
  ];
  
  networking.hostName = "nixos-chris";
  system.stateVersion = "23.11";
}
```

### Phase 3: Unify Home Manager Configurations (High Risk)

#### 3.1 Create Role-Based Home Manager Modules

**Create `hm/modules/server-core.nix`:**

```nix
# Minimal server home configuration
{
  home.packages = with pkgs; [
    btop htop tmux git neovim
    ripgrep fd jq dig
  ];
  
  programs.tmux.enable = true;
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    # Minimal zsh config
  };
}
```

**Create `hm/modules/desktop-core.nix`:**

```nix
# Core desktop packages and services
{
  imports = [
    ./server-core.nix
    ../../modules/git.nix
    ../../modules/firefox.nix
    # ... other desktop modules
  ];
  
  home.packages = with pkgs; [
    # Development tools
    gh lazygit
    # GUI applications
    google-chrome slack
    # ... other desktop packages
  ];
}
```

#### 3.2 Simplify Home Manager Files

**New `hm/anton.nix`:**

```nix
{
  imports = [ ./modules/server-core.nix ];
  # Host-specific packages only
}
```

**New `hm/sam.nix`:**

```nix
{
  imports = [ ./modules/server-core.nix ];
  # Print server specific packages
}
```

### Phase 4: Remove Desktop Bloat from Servers

#### 4.1 Services to Remove from Servers

**From anton & sam:**

- ❌ X11/GNOME desktop environment
- ❌ GDM display manager
- ❌ PipeWire/audio services (unless needed for specific tasks)
- ❌ Bluetooth services
- ❌ Desktop applications (Firefox, etc.)
- ❌ 1Password GUI applications

**From ben (keep minimal GUI for maintenance):**

- ⚠️ Keep minimal X11 + Awesome (for rare desktop access)
- ❌ Remove audio/bluetooth services
- ❌ Remove unnecessary desktop applications

#### 4.2 Package Cleanup

**Server packages to remove:**

- GUI applications (Firefox, Chrome, Slack)
- Desktop development tools (unless specifically needed)
- Multimedia packages
- Desktop-specific utilities

**Keep on servers:**

- Core CLI tools (git, neovim, tmux, btop)
- Development essentials (for maintenance)
- Network tools
- Server monitoring tools

## Implementation Steps

### Step 1: Create New Modules (Safe)

1. Create `modules/base.nix` with common configuration
1. Create `modules/server-base.nix` for server defaults
1. Create `modules/desktop-base.nix` for desktop defaults
1. Create `modules/printing.nix` for Sam's printer configuration
1. Create `modules/adguard.nix` for Ben's AdGuard configuration

### Step 2: Test Base Modules (Low Risk)

1. Add base module imports to one server (anton) first
1. Test rebuild and functionality
1. Gradually apply to other servers

### Step 3: Standardize System Versions (Medium Risk)

1. Upgrade anton and sam to 24.05 (current versions)
1. Test all services after upgrade
1. Document any breaking changes

### Step 4: Simplify Server Configurations (Medium Risk)

1. Remove desktop environments from anton and sam
1. Simplify ben's configuration (keep minimal GUI)
1. Clean up unnecessary services and packages

### Step 5: Unify Home Manager (High Risk)

1. Create shared Home Manager modules
1. Test with one server first
1. Gradually migrate all hosts
1. Remove duplicated configurations

### Step 6: Final Cleanup (Low Risk)

1. Remove unused files and imports
1. Update documentation
1. Validate all configurations build successfully

## Expected Benefits

1. **Reduced Maintenance**: Common configurations managed in one place
1. **Improved Security**: Consistent security settings across all hosts
1. **Better Performance**: Servers without unnecessary desktop bloat
1. **Easier Updates**: Unified module structure simplifies updates
1. **Clear Role Separation**: Desktop vs server configurations clearly defined

## Risk Mitigation

1. **Backup Strategy**: Ensure all configurations can be rolled back
1. **Gradual Migration**: Test changes on non-critical hosts first
1. **Service Monitoring**: Verify all services remain functional after changes
1. **Documentation**: Document all configuration changes and rationale

## Files to Create/Modify

### New Files:

- `modules/base.nix`
- `modules/server-base.nix`
- `modules/desktop-base.nix`
- `modules/printing.nix`
- `modules/adguard.nix`
- `modules/chris-desktop.nix`
- `hm/modules/server-core.nix`
- `hm/modules/desktop-core.nix`

### Files to Modify:

- All host `configuration.nix` files
- All Home Manager files
- `flake.nix` (potentially simplify host definitions)

### Files to Remove:

- Redundant configuration snippets
- Unused module imports
- Duplicate package lists

This plan provides a clear path forward for creating a more maintainable, secure, and efficient NixOS configuration setup while respecting the different roles of each machine.

