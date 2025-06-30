# Vaultwarden Setup with Tailscale HTTPS

This document explains the final working configuration for self-hosting Vaultwarden on NixOS with Tailscale and HTTPS support.

## Overview

- **Service**: Vaultwarden (unofficial Bitwarden server)
- **VPN**: Tailscale for secure access
- **HTTPS**: Tailscale certificates with Let's Encrypt
- **Platform**: NixOS

## Configuration

### NixOS Configuration (`hosts/ben/configuration.nix`)

```nix
# Tailscale VPN
services.tailscale = {
  enable = true;
  extraUpFlags = ["--accept-dns"];
};

# Trust Tailscale interface in firewall
networking.firewall.enable = true;
networking.firewall.trustedInterfaces = ["tailscale0"];

# Vaultwarden service
services.vaultwarden = {
  enable = true;
  config = {
    ROCKET_PORT = 8222;
    ROCKET_ADDRESS = "0.0.0.0";
    DOMAIN = "https://ben.tail0b5947.ts.net:8222";
    ROCKET_TLS = ''{certs="/etc/vaultwarden/ben.tail0b5947.ts.net.crt",key="/etc/vaultwarden/ben.tail0b5947.ts.net.key"}'';
  };
};

# Copy Tailscale certificates to system location
system.activationScripts.vaultwarden-certs = ''
  mkdir -p /etc/vaultwarden
  cp /home/denis/dotfiles/ben.tail0b5947.ts.net.crt /etc/vaultwarden/
  cp /home/denis/dotfiles/ben.tail0b5947.ts.net.key /etc/vaultwarden/
  chown vaultwarden:vaultwarden /etc/vaultwarden/ben.tail0b5947.ts.net.*
  chmod 600 /etc/vaultwarden/ben.tail0b5947.ts.net.*
'';
```

## Setup Steps

### 1. Enable Tailscale HTTPS in Admin Console
- Go to Tailscale admin console
- Navigate to Settings → HTTPS certificates
- Enable HTTPS certificates feature

### 2. Generate Tailscale Certificate
```bash
sudo tailscale cert ben.tail0b5947.ts.net
```

This creates:
- `ben.tail0b5947.ts.net.crt` (public certificate)
- `ben.tail0b5947.ts.net.key` (private key)

### 3. Deploy Configuration
```bash
sudo nixos-rebuild switch
```

## Access URLs

- **Web Vault**: `https://ben.tail0b5947.ts.net:8222`
- **Mobile App Server**: `https://ben.tail0b5947.ts.net:8222`

## Security Features

- **VPN-Only Access**: Service only accessible through Tailscale network
- **HTTPS Required**: WebCrypto API requires secure context
- **Let's Encrypt Certificate**: Valid certificate trusted by all devices
- **Firewall Protection**: Only Tailscale interface trusted

## Key Benefits

1. **No Public Exposure**: Vaultwarden not accessible from internet
2. **Valid HTTPS**: Mobile apps work without certificate warnings
3. **Easy Client Setup**: Standard Bitwarden apps work seamlessly
4. **Automatic Certificates**: Tailscale handles Let's Encrypt renewal
5. **Cross-Platform**: Works on iOS, Android, desktop apps

## Troubleshooting

### WebCrypto Error
If you see "Could not instantiate WebCryptoFunctionService", ensure:
- URL uses HTTPS (not HTTP)
- Certificate is valid and accessible
- Service is running on correct port

### Connection Issues
- Verify Tailscale is connected on client device
- Check service status: `systemctl status vaultwarden`
- Check logs: `journalctl -u vaultwarden -f`

### Certificate Problems
- Regenerate certificate: `sudo tailscale cert ben.tail0b5947.ts.net`
- Rebuild NixOS: `sudo nixos-rebuild switch`
- Verify permissions: certificates should be owned by vaultwarden user

## Alternative Approaches Not Used

- **Caddy Reverse Proxy**: Removed for simplicity (Rocket handles TLS directly)
- **Self-Signed Certificates**: Would require manual trust on each device
- **DNS-01 Challenge**: More complex than Tailscale's built-in solution
- **Public Exposure**: Avoided for security reasons