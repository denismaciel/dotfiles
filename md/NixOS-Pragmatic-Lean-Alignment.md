# Pragmatic Lean Alignment for NixOS Hosts

This document proposes small, high‑impact changes to make configurations leaner and more aligned. It builds on what’s already in the repo and avoids unnecessary abstraction. Small duplication is fine. Assumptions: sam, anton, ben are servers; chris is the daily driver.

## Goals
- Consistent base behavior across hosts.
- Reduce GUI/services on servers to cut resource usage and noise.
- Centralize only the highest‑value duplication (user, base Nix settings).
- Keep host files readable and hardware/service specifics local.

## High‑Impact Changes
- Import `modules/denis-user.nix` on all hosts and remove per‑host user/zsh/sudo/openssh duplication.
- Centralize shared Nix settings and GC into a tiny base module (`modules/base-core.nix`).
- Treat servers as headless by default; disable desktop/audio/bluetooth/printing there.
- Standardize Tailscale and firewall handling for servers; keep chris client‑mode.
- Use the existing HM `hm/server-base.nix` on all servers (move ben to it).

## 1) Create a tiny core base module (all hosts)
Add `modules/base-core.nix` with only the settings that are identical across machines today.

```nix
{ ... }: {
  nix.settings = {
    trusted-users = ["denis"];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
```

Then import it in all host files (top of `imports`):

```nix
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-core.nix
    ../../modules/denis-user.nix
    # ...existing imports
  ];
```

Impact: removes repeated `nix.settings` and `nix.gc` fragments across all hosts.

## 2) Use `modules/denis-user.nix` everywhere
All hosts currently inline user config; replace those blocks with an import of `../../modules/denis-user.nix`. Per‑host groups can be extended locally if needed (e.g., add `audio` on desktop).

Example (chris):

```nix
imports = [
  ./hardware-configuration.nix
  ../../modules/base-core.nix
  ../../modules/denis-user.nix
  # existing modules...
];

# Remove the inline users.users.denis block.
# If needed, extend groups:
users.users.denis.extraGroups = users.users.denis.extraGroups ++ [ "audio" ];
```

Impact: single source for user shell, SSH keys, sudo policy, zsh enablement, OpenSSH enablement.

## 3) Server baseline hardening and de-bloat
Apply to sam, anton, ben.

- Disable desktop stack: remove `services.displayManager`, `services.xserver`, `services.pipewire`, `services.printing`, `services.blueman`, `hardware.bluetooth` from server host configs.
- Disable laptop power behaviors: set
  - `systemd.targets.sleep.enable = false;`
  - `systemd.targets.suspend.enable = false;`
  - `systemd.targets.hibernate.enable = false;`
  - `systemd.targets.hybrid-sleep.enable = false;`
- Keep `networking.networkmanager.enable = true` if it’s working for you (pragmatic); otherwise, consider `systemd-networkd` later.
- Standardize SSH and firewall:
  - `services.openssh.enable = true;`
  - `services.openssh.ports = [22 443 2222 7422];`
  - `services.openssh.settings.PasswordAuthentication = false;` (keep `true` only where you truly need it — e.g., local access on sam)
  - `networking.firewall.enable = true;`
  - `networking.firewall.trustedInterfaces = [ "tailscale0" ];` (optional but useful)
- Tailscale defaults: `services.tailscale.enable = true;`
  - ben only: `extraUpFlags = [ "--accept-dns" "--advertise-exit-node" ];` plus `boot.kernel.sysctl."net.ipv4.ip_forward" = 1;`
- Docker: keep `virtualisation.docker.enable = true;` on servers that run containers.

Impact: less memory/CPU on servers; simpler, safer baseline.

## 4) Move ben to server profile
Today ben behaves like a workstation (GUI + large HM package set). Given ben is a server:

- Host config: remove the GUI/audio/printing/bluetooth bits mentioned above.
- HM: switch to `hm/server-base.nix` (same as anton and sam) unless you truly need GUI workloads.
  - If ben needs a couple of GUI tools, add only those as targeted `home.packages` or keep a small dedicated HM file that imports `server-base.nix` and adds the few extras.

Minimal example to switch ben:

```nix
# flake.nix
nixosConfigurations.ben = mkNixosSystem "ben" [
  ./hosts/ben/configuration.nix
  home-manager.nixosModules.home-manager
  (hmFor ./hm/server-base.nix (_: {}))
];
```

Impact: significant footprint reduction and alignment with other servers.

## 5) Keep chris as desktop, tighten a bit
Chris is your daily driver, so keep desktop features. Pragmatic tweaks:

- Keep `geoclue2` + `automatic-timezoned` on chris only; use static time zone on servers.
- Keep `stylix`, `graphics.nix`, and window manager modules on chris only.
- Keep `programs._1password*` on chris (and any workstation), not on servers.
- Consider moving big UI apps to HM rather than `environment.systemPackages` to keep the system closure cleaner.

Impact: desktop stays rich; separation from servers is clearer.

## 6) What NOT to change (pragmatic calls)
- `system.stateVersion`: do not unify retroactively — leave as-is per machine to avoid migrations.
- `networking.networkmanager.enable`: keep it on servers if it works reliably for you.
- `nixpkgs` channel: you’re on `nixpkgs/master`; changing to stable is optional and out of scope here.

## Quick Per‑Host Checklist

### chris (daily driver)
- Import `base-core.nix` and `denis-user.nix`.
- Keep desktop modules (`graphics.nix`, `polybar.nix`, `stylix`, X11/WM, pipewire, printing, bluetooth).
- Keep Tailscale client mode with your existing `extraUpFlags`.
- Optionally move some GUI apps to HM.

### sam (server / print)
- Import `base-core.nix` and `denis-user.nix`.
- Keep printing and Avahi; drop any remaining GUI/audio/bluetooth.
- Keep SSH `PasswordAuthentication = true` only if truly needed; otherwise set to `false`.
- Ensure firewall open for CUPS as already done.

### anton (server)
- Import `base-core.nix` and `denis-user.nix`.
- Ensure no GUI/audio/printing/bluetooth; keep SSH hardened and firewall enabled.

### ben (server / exit node + services)
- Import `base-core.nix` and `denis-user.nix`.
- Remove GUI/audio/printing/bluetooth from host config.
- Switch HM to `hm/server-base.nix` and add only necessary extras.
- Keep Tailscale exit node and AdGuard/Vaultwarden services.

## Rollout Plan
- Step 1: Add `modules/base-core.nix` and import it + `denis-user.nix` in all hosts.
- Step 2: Servers — remove GUI/audio/printing/bluetooth; standardize SSH, firewall, Tailscale.
- Step 3: Move ben to `hm/server-base.nix` and trim packages.
- Step 4: Verify each host builds; deploy one at a time.

## Appendix: Minimal diffs to apply

1) All hosts — add imports:

```diff
 imports = [
   ./hardware-configuration.nix
+  ../../modules/base-core.nix
+  ../../modules/denis-user.nix
   # existing modules...
 ];
```

2) All hosts — remove inline `users.users.denis` blocks and inline `programs.zsh.enable`, `security.sudo.wheelNeedsPassword`, `services.openssh.enable` if present (handled by `denis-user.nix`).

3) Servers — remove desktop/audio/printing/bluetooth blocks. For example on ben:

```diff
- services.displayManager = { ... };
- services.xserver = { ... };
- services.pipewire = { ... };
- services.printing.enable = true;
- services.avahi = { ... };
- services.blueman.enable = true;
- hardware.bluetooth.enable = true;
```

4) Servers — standardize SSH and firewall (unless sam needs password auth):

```nix
services.openssh.ports = [22 443 2222 7422];
services.openssh.settings.PasswordAuthentication = false; # except sam if needed
networking.firewall.enable = true;
networking.firewall.trustedInterfaces = [ "tailscale0" ];
```

5) ben — keep service specifics (Vaultwarden, AdGuardHome, Tailscale exit node) as is.

