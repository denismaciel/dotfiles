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

## Automated Backup System

### Backup Configuration

The Vaultwarden instance includes automated daily backups using a custom NixOS module:

```nix
# Enable automated backups
services.vaultwarden-backup = {
  enable = true;
  schedule = "daily";
};
```

### Backup Features

- **SQLite .backup Command**: Uses SQLite's built-in backup for database consistency
- **Zero Downtime**: Backups run without stopping Vaultwarden service
- **Complete Data**: Backs up database, encryption keys, attachments, and sends
- **Syncthing Integration**: Backups stored in `/home/denis/Sync/backups/vaultwarden/`
- **Automatic Retention**: Keeps 30 days of backups
- **Integrity Verification**: Each backup is verified after creation

### Manual Backup

```bash
# Run backup manually
sudo vaultwarden-backup

# Check backup logs
cat /home/denis/Sync/backups/vaultwarden/backup.log
```

### Restore Testing

Test backups using Docker without affecting production:

```bash
# Test latest backup
test-vaultwarden-restore

# Test specific backup
test-vaultwarden-restore 8224 2024-07-02_10-30-00

# Test on different port
test-vaultwarden-restore 8225
```

### Backup Contents

Each backup includes:
- `db.sqlite3` - Main database (consistent SQLite backup)
- `rsa_key.pem` - Encryption key (critical for data recovery)
- `attachments/` - File attachments
- `sends/` - Bitwarden Send files
- `icon_cache/` - Website icons

### Backup Schedule

- **Frequency**: Daily at random time (15-minute window)
- **Storage**: Syncthing folder (replicated across all devices)
- **Retention**: 30 days of backups
- **Monitoring**: Logs all operations with timestamps

### Disaster Recovery

1. Stop Vaultwarden service
2. Restore backup files to `/var/lib/bitwarden_rs/`
3. Ensure proper ownership (vaultwarden:vaultwarden)
4. Start Vaultwarden service

## Alternative Approaches Not Used

- **Caddy Reverse Proxy**: Removed for simplicity (Rocket handles TLS directly)
- **Self-Signed Certificates**: Would require manual trust on each device
- **DNS-01 Challenge**: More complex than Tailscale's built-in solution
- **Public Exposure**: Avoided for security reasons
- **Filesystem Snapshots**: SQLite .backup is more reliable for consistency