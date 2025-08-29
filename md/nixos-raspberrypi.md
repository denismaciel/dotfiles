
# Running NixOS on Raspberry Pi 3B

This document summarizes the steps taken to get a **Raspberry Pi 3B** running with **NixOS** from scratch, starting on a NixOS laptop and ending with a headless Pi managed via flakes.

## 1. Build an Installer Image (on laptop)

```bash
git clone https://github.com/nvmd/nixos-raspberrypi.git
cd nixos-raspberrypi
nix build .#installerImages.rpi3 -L
```

Outputs:

```
result/sd-image/nixos-installer-rpi3-uboot.img.zst
```

## 2. Flash the SD Card

```bash
lsblk -o NAME,SIZE,RM,MODEL,MOUNTPOINTS      # find your SD (e.g. /dev/sda)
sudo nix shell nixpkgs#util-linux -c umount -R /dev/sda* 2>/dev/null || true
nix run nixpkgs#caligula -- burn -o /dev/sda ./result/sd-image/nixos-installer-rpi3-uboot.img.zst
# (alt) manual:
# nix shell nixpkgs#zstd nixpkgs#coreutils -c sh -c \
# 'zstd -d -c ./result/sd-image/nixos-installer-rpi3-uboot.img.zst | sudo dd of=/dev/sda bs=4M status=progress conv=fsync oflag=direct'
# sudo nix shell nixpkgs#coreutils -c sync
```

## 2.5. (Temporary) Add SSH Key to the SD **by hand** (pre-boot)

> **Why:** the build didn’t pick up our key automatically; until we automate it, we inject the key directly onto the freshly flashed SD, so first boot is headless.

I asked an agent to do that for me.

```bash
# Identify the root partition on the SD (usually /dev/sda2)
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS /dev/sda

# Create a mount point and mount the root partition (replace sda2 if different)
sudo mkdir -p /mnt/rpi-root
sudo nix shell nixpkgs#util-linux -c mount /dev/sda2 /mnt/rpi-root

# Add your key for root
sudo mkdir -p /mnt/rpi-root/root/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFJLQFWmH33Gmo2pGMtaQ0gPfAuqMZwodMUvDJwFTMy denispmaciel@gmail.com' \
  | sudo tee -a /mnt/rpi-root/root/.ssh/authorized_keys
sudo chmod 700 /mnt/rpi-root/root/.ssh
sudo chmod 600 /mnt/rpi-root/root/.ssh/authorized_keys

# Optional: harden SSH (on the image)
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /mnt/rpi-root/etc/ssh/sshd_config 2>/dev/null || true
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /mnt/rpi-root/etc/ssh/sshd_config 2>/dev/null || true

# Unmount and flush
sudo nix shell nixpkgs#util-linux -c umount /mnt/rpi-root
sudo nix shell nixpkgs#coreutils -c sync
```

## 3. First Boot on the Pi

* Insert the SD, plug **Ethernet**, power on.
* LEDs: **red** solid (power), **green** irregular blink (SD activity).
* Wait \~1 minute (first boot expands root FS).

## 4. Find the Pi on the Network

```bash
nix shell nixpkgs#avahi -c avahi-browse -a -t
nix shell nixpkgs#iputils -c ping -c 3 rpi3.local
nix shell nixpkgs#nmap -c nmap -p 22 --open 192.168.1.0/24
```

(Confirm MAC prefix like `b8:27:eb` / `dc:a6:32` for Raspberry Pi.)

## 5. SSH In

```bash
ssh root@<pi-ip>     # e.g., ssh root@192.168.1.85
```

If you see a password prompt, key injection failed—repeat **2.5**.

## 6. Bootstrap a Real Flake Config (on the Pi)

```bash
nixos-generate-config
```

This creates `/etc/nixos/configuration.nix` and `/etc/nixos/hardware-configuration.nix`.

## 7. Migrate Configuration to Flake Repository

### 7.1. Copy Configuration Files from Pi

From your main machine (not the Pi):

```bash
# Copy the configuration files to temporary location
scp root@<pi-ip>:/etc/nixos/hardware-configuration.nix /tmp/zeze-hardware-configuration.nix
scp root@<pi-ip>:/etc/nixos/configuration.nix /tmp/zeze-configuration.nix

# Create host directory in your dotfiles repo
mkdir -p hosts/zeze
cp /tmp/zeze-*.nix hosts/zeze/
```

### 7.2. Update flake.nix

Add the Pi to your systems and nixosConfigurations:

```nix
# In the systems definition, add:
systems = {
  # ... other systems ...
  zeze = "aarch64-linux";  # For Raspberry Pi 3B+
};

# In nixosConfigurations, add:
zeze = mkNixosSystem "zeze" [
  ./hosts/zeze/configuration.nix
  home-manager.nixosModules.home-manager
  (hmFor ./hm/server-base.nix (_: { }))
];
```

### 7.3. Configure the Pi for Flake Management

Edit `hosts/zeze/configuration.nix` to match your other hosts:

```nix
# Raspberry Pi 3B+ configuration for zeze
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-core.nix
    ../../modules/denis-user.nix
  ];

  # Use the extlinux boot loader for Raspberry Pi
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Networking
  networking.hostName = "zeze";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH
    trustedInterfaces = [ "tailscale0" ]; # If using Tailscale
  };

  # Localization
  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";

  # SSH settings
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };

  # Tailscale VPN (optional but recommended)
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--accept-dns" ];
  };

  # System packages (minimal for Pi)
  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    htop
  ];

  # State version - DO NOT CHANGE
  system.stateVersion = "25.05";
}
```

### 7.4. Add Raspberry Pi Binary Cache

To speed up builds, add the Raspberry Pi cache to your `flake.nix`:

```nix
nixConfig = {
  substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
    "https://nixos-raspberrypi.cachix.org"  # Add this
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="  # Add this
  ];
};
```

### 7.5. Add Makefile Target

Add a rebuild target for the Pi in your `Makefile`:

```makefile
rebuild-zeze:
	nixos-rebuild switch --flake ~/dotfiles#zeze --target-host zeze --sudo
```

### 7.6. Initial Deployment

**Important:** The first deployment must be done as root since the denis user doesn't exist yet:

```bash
# Commit your changes first
git add hosts/zeze/ flake.nix Makefile
git commit -m "Add zeze (Raspberry Pi 3B+) host configuration"

# Deploy to the Pi (this will create the denis user)
nixos-rebuild switch --flake ~/dotfiles#zeze --target-host root@<pi-ip> --sudo
```

The deployment will:
- Create the `denis` user with your SSH key
- Disable root login
- Apply all your standard modules
- Set up networking with the new hostname

**Note:** The Pi may get a new IP address after deployment due to hostname change. Check with:

```bash
ip neigh | grep -i "b8:27:eb"  # Look for Raspberry Pi MAC address
```

### 7.7. Post-Deployment

After successful deployment:

1. SSH as the regular user: `ssh denis@<new-ip>` or `ssh denis@zeze` (if using Tailscale)
2. Future updates: `make rebuild-zeze`
3. If using Tailscale, authenticate it:
   ```bash
   ssh denis@zeze "sudo tailscale up --accept-dns"
   ```

## Troubleshooting

### If SSH Access is Lost

1. Check if Pi is alive: `ping <last-known-ip>`
2. Scan network for Pi: `nmap -sn 192.168.1.0/24`
3. Check ARP cache: `ip neigh | grep -i "b8:27:eb"`
4. If needed, connect monitor/keyboard for physical access
5. Rollback if necessary: `nixos-rebuild switch --rollback`

### Build Takes Forever

Building for ARM on x86 uses QEMU emulation which is slow. The Raspberry Pi cache helps, but initial builds may still take 10-20 minutes.

### Network Changes After Deployment

The Pi may get a new IP from DHCP after hostname changes. Always check the network for the new IP using MAC address patterns (b8:27:eb for older Pi models).

