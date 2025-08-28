# Secrets Management Plan (sops-nix)

This plan introduces sops-nix for managing secrets across this flake-based NixOS + Home Manager setup. It keeps secrets out of the repo in plaintext, enables per-host scoping, and wires them into system and HM modules safely.

## What / Why / How

- What: Use sops-nix to manage future secrets (e.g., Tailscale auth key, Vaultwarden TLS key/cert, API tokens).
- Why: Avoid committing plaintext secrets; automate provisioning with correct ownership/modes; keep deploys reproducible.
- How: Add `sops-nix` to `flake.nix`, define per-host recipients, store encrypted files under `secrets/`, and reference them via `sops.secrets` in NixOS/HM modules.

References (checked):
- sops-nix README (usage, flakes, age/SSH): https://github.com/Mic92/sops-nix
- NixOS Tailscale option (auth key file exists): https://search.nixos.org/options?query=services.tailscale.authKeyFile

## Current Configuration: Likely Secret Touchpoints

- Tailscale across hosts (`hosts/*/configuration.nix`)
  - Today: `services.tailscale.enable = true;` with `extraUpFlags`. No auth key file wired yet.
  - Plan: Manage a reusable or ephemeral `authKey` via `sops.secrets`, per-host where needed.

- Vaultwarden on `ben` (`hosts/ben/configuration.nix` and `md/vaultwarden-setup.md`)
  - Today: TLS cert/key are copied from files in the dotfiles path via `system.activationScripts.vaultwarden-certs`.
  - Risk: Private key currently expected to live under the repo path on disk; easy to leak/commit accidentally.
  - Plan: Store TLS key (and optionally cert) via `sops.secrets` with `owner/group = vaultwarden`, correct modes, and reference paths in `ROCKET_TLS`. Also consider setting an `ADMIN_TOKEN` via a sops-managed env file.

- AdGuardHome on `ben`
  - Today: Minimal config. If an admin password or upstream credentials are introduced, manage them via sops (either a templated YAML or an env file).

- Home Manager (HM) on `chris`
  - Today: `age` and `sops` are already in `home.packages` (no HM sops-nix integration yet).
  - Plan: Use HM’s `sops` module for user-level tokens (e.g., `gh`, `stripe-cli`, API tokens) when needed.

- Cloudflare Warp (`modules/warp.nix`)
  - Today: No account/team token used. If enrollment tokens or service tokens are added (Teams/ZTNA), manage them via sops.

## Implementation Plan

1) Add sops-nix to flake inputs and import module

```nix
# flake.nix
{
  inputs = {
    # ...existing
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, sops-nix, ... }: {
    nixosConfigurations = {
      ben = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/ben/configuration.nix
          sops-nix.nixosModules.sops
          # ...existing
        ];
      };
      # repeat per host: chris, anton, sam
    };
  };
}
```

2) Choose decryption method and recipients

- Preferred: `age` recipients derived from each host’s SSH Ed25519 host key.
- Configure decryption on hosts:

```nix
# Per-host module (e.g., hosts/ben/configuration.nix)
{
  # Automatically import SSH host key as an age key
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
```

- In the repo, maintain `.sops.yaml` to define recipients per host and defaults, e.g.:

```yaml
# .sops.yaml (example skeleton)
creation_rules:
  - path_regex: secrets/ben/.*
    age:
      - age1benHostRecipientKey...
  - path_regex: secrets/chris/.*
    age:
      - age1chrisHostRecipientKey...
  - path_regex: secrets/common/.*
    age:
      - age1benHostRecipientKey...
      - age1chrisHostRecipientKey...
      # add other hosts as needed
```

Notes:
- You can derive an age recipient from the host’s SSH ed25519 public key: `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub` (see sops-nix README).
- For editor access, add your personal age public key to `creation_rules` as well.

3) Create encrypted secrets files under `secrets/`

- Directory layout (example):

```
secrets/
  ben/
    tailscale.yaml
    vaultwarden-tls.key
    vaultwarden-tls.crt
    vaultwarden.env   # optional: ADMIN_TOKEN, SMTP creds
  chris/
    tailscale.yaml
  sam/
    tailscale.yaml
  common/
    gh-token
    stripe-key
```

- Create/edit with sops:

```bash
# YAML example
sops secrets/ben/tailscale.yaml

# Binary files (e.g., .key/.crt) can also be encrypted with sops
sops --encrypt --input-type binary --output-type binary \
  --in-place secrets/ben/vaultwarden-tls.key
```

4) Wire secrets into NixOS

- Tailscale auth key (per host):

```nix
# hosts/ben/configuration.nix
{
  # Expose the secret on-disk at activation with proper perms (root-only)
  sops.secrets."tailscale/auth-key" = {
    sopsFile = ./../../secrets/ben/tailscale.yaml;
    # If YAML, use a template (see below) or a single-value file
    mode = "0400";
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
    extraUpFlags = [ "--accept-dns" ];
  };
}
```

- Vaultwarden TLS key/cert (replace activation script copy):

```nix
# hosts/ben/configuration.nix
{
  sops.secrets."vaultwarden/tls.key" = {
    sopsFile = ./../../secrets/ben/vaultwarden-tls.key;
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
    path = "/etc/vaultwarden/ben.tail0b5947.ts.net.key";
  };
  sops.secrets."vaultwarden/tls.crt" = {
    sopsFile = ./../../secrets/ben/vaultwarden-tls.crt;
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0444";
    path = "/etc/vaultwarden/ben.tail0b5947.ts.net.crt";
  };

  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "0.0.0.0";
      DOMAIN = "https://ben.tail0b5947.ts.net:8222";
      ROCKET_TLS = ''{certs="/etc/vaultwarden/ben.tail0b5947.ts.net.crt",key="/etc/vaultwarden/ben.tail0b5947.ts.net.key"}'';
    };
  };
}
```

Optional (recommended): move admin/tokenized config out of `.config` into an env file managed by sops:

```nix
# secrets/ben/vaultwarden.env -> ADMIN_TOKEN=... (sops-encrypted)
sops.secrets."vaultwarden/env" = {
  sopsFile = ./../../secrets/ben/vaultwarden.env;
  owner = "vaultwarden";
  group = "vaultwarden";
  mode = "0400";
};

systemd.services.vaultwarden.serviceConfig.EnvironmentFile =
  config.sops.secrets."vaultwarden/env".path;
```

5) Wire secrets into Home Manager (user-level)

If you later need per-user tokens (e.g., `gh`, `stripe-cli`, `gcloud`), use HM’s sops integration:

```nix
# In HM module (e.g., hm/chris/default.nix) after importing sops HM module via flake
{ config, lib, ... }:
{
  # Example: write token to ~/.config/gh/token
  sops.secrets."gh/token" = {
    sopsFile = ../../secrets/common/gh-token;
    path = "${config.home.homeDirectory}/.config/gh/token";
    mode = "0600";
  };
}
```

6) Remove plaintext paths and scripts that copy secrets

- Delete/replace `system.activationScripts.vaultwarden-certs` in `hosts/ben/configuration.nix` once sops-managed files are in place.
- Ensure no `*.key`/`*.crt`/tokens live unencrypted in the repo or `$HOME/dotfiles`.

## Bootstrap & Operations

- Generate editor key (age):

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
# or convert SSH ed25519 key
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
```

- Find host recipients from SSH host keys:

```bash
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub # sanity-check key exists
sudo cat /etc/ssh/ssh_host_ed25519_key.pub | nix-shell -p ssh-to-age --run 'ssh-to-age'
# add output to .sops.yaml under the appropriate rule
```

- Create/edit secrets:

```bash
sops secrets/ben/tailscale.yaml
sops --input-type binary --output-type binary --in-place secrets/ben/vaultwarden-tls.key
```

- Rebuild:

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#ben
```

- Rotation:
  - Update the encrypted file with `sops`.
  - Commit and rebuild; sops-nix writes atomically and updates permissions.

## Security Notes

- sops-nix decrypts at activation; files are not embedded in derivations or leaked via store paths.
- Always set strict `owner/group/mode` for service secrets.
- Prefer per-host scoping in `.sops.yaml` to prevent overexposure.
- For Tailscale TLS: long-term ideal is automating `tailscale cert` renewal into a root-only path and referencing it directly; sops works as an interim if you must pre-provision key/cert.

## Next Steps (for this repo)

- Add `sops-nix` to `flake.nix` and import for all hosts.
- Add `.sops.yaml` with recipients for `ben`, `chris`, `anton`, `sam` (derive from host SSH keys and add your editor key).
- Create `secrets/` with:
  - `ben/tailscale.yaml` containing an auth key (ephemeral or reusable) and/or use a single-value file.
  - `ben/vaultwarden-tls.key` and `ben/vaultwarden-tls.crt` (encrypted), then remove the activation script copy.
  - Optional: `ben/vaultwarden.env` with `ADMIN_TOKEN` and SMTP creds if configured.
  - Placeholders for future tokens under `common/` (e.g., `gh-token`, `stripe-key`).
- Update NixOS and HM modules to reference `config.sops.secrets.*.path` where needed.

