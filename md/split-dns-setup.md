# Split DNS with Tailscale and AdGuard on NixOS

## Overview

This setup uses systemd-resolved to implement split DNS, where:
- Tailscale MagicDNS handles internal Tailscale hostnames (`.ts.net` domains)
- AdGuard on zeze filters ads and handles all other DNS queries
- Automatic fallback to public DNS if AdGuard is unavailable

## How Split DNS Works (ELI5)

Imagine your computer needs a **phone book** to find websites. Split DNS is like having **two different phone books** for different types of calls:

### 📚 The Two Phone Books

1. **Tailscale's Phone Book** (100.100.100.100)
   - Only knows Tailscale machine names (like `ben.tail0b5947.ts.net`)
   - Think of it as your "internal office directory"

2. **AdGuard's Phone Book** (100.117.76.42 on zeze)
   - Knows all regular websites (google.com, reddit.com, etc.)
   - Also blocks ads by saying "that ad server doesn't exist!"
   - Has backup phone books (Cloudflare, Google) if it can't find something

### 🎯 The Traffic Cop: systemd-resolved

There's a **traffic cop** (systemd-resolved) sitting at address `127.0.0.53` who decides which phone book to use:

```
You: "Hey, where's ben.tail0b5947.ts.net?"
Traffic Cop: "That ends in .ts.net! Let me check Tailscale's phone book... → 100.74.57.103"

You: "Hey, where's google.com?"  
Traffic Cop: "That's a regular website! Let me check AdGuard's phone book... → 142.250.200.110"
```

### 🔧 How It Gets Set Up

1. **NetworkManager** tells the traffic cop: "You're in charge of DNS now!"
2. **Tailscale** tells the traffic cop: "I handle anything ending in `.ts.net` or `.in-addr.arpa`"
3. **Your NixOS config** tells the traffic cop: "For everything else, use AdGuard. If it's down, use the fallbacks."

### 🎭 The Magic

When you type a website:
- Your browser asks `127.0.0.53` (the traffic cop)
- Traffic cop checks: "Is this a Tailscale name?"
  - YES → Asks Tailscale's MagicDNS
  - NO → Asks AdGuard on zeze (which blocks ads!)
- You get the answer back

If zeze is sleeping (offline), the traffic cop automatically asks the backup phone books (Cloudflare/Google) so you never lose internet!

## Configuration

### AdGuard Module (`modules/adguard.nix`)

```nix
{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    settings = {
      dns = {
        bind_port = 53;
        bind_hosts = [
          "0.0.0.0"
          "::"
        ];
      };
    };
  };
}
```

### Client Configuration (e.g., `hosts/chris/configuration.nix`)

```nix
{ config, pkgs, ... }:

{
  # NetworkManager uses systemd-resolved
  networking = {
    nameservers = [ ];  # Empty - let systemd-resolved handle DNS
    hostName = "chris";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";  # Use systemd-resolved for DNS
    };
    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 3000 ];
    };
  };

  # systemd-resolved configuration for split DNS
  services.resolved = {
    enable = true;
    llmnr = "false";  # Disable LLMNR for security
    dnssec = "false";  # Set to "allow-downgrade" if you want DNSSEC
    extraConfig = ''
      DNS=100.117.76.42
      FallbackDNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
      Domains=~.
    '';
  };

  # Tailscale with MagicDNS enabled
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--accept-dns=true"  # Let Tailscale inject split-DNS rules for .ts.net domains
      "--exit-node=100.74.57.103"
      "--exit-node-allow-lan-access=true"
    ];
  };
}
```

### Server Configuration (`hosts/zeze/configuration.nix`)

```nix
{
  imports = [
    # ... other imports ...
    ../../modules/adguard.nix
  ];

  networking.nameservers = [ "127.0.0.1" ];  # Use local AdGuard
  
  # ... rest of configuration ...
}
```

## The Key: Proper systemd-resolved Configuration

### Why It Works

The magic is in the `services.resolved.extraConfig`:

```ini
DNS=100.117.76.42
FallbackDNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
Domains=~.
```

- **`DNS=100.117.76.42`** - ONLY AdGuard as primary DNS (no other servers!)
- **`FallbackDNS=...`** - Public DNS servers used ONLY if AdGuard fails
- **`Domains=~.`** - Routes ALL domains through global DNS (not per-interface DNS)

### Critical: Avoid Multiple DNS Servers

❌ **DON'T DO THIS:**
```ini
DNS=100.117.76.42 1.1.1.1 8.8.8.8
```

If you list multiple DNS servers, systemd-resolved will:
- Test them for speed/availability
- Pick what it thinks is "best" (often Cloudflare because it's faster)
- Stick with that server until it fails
- Your AdGuard blocking won't work!

✅ **DO THIS:**
```ini
DNS=100.117.76.42
FallbackDNS=1.1.1.1 8.8.8.8
```

With only AdGuard in `DNS=`, systemd-resolved has no choice but to use it first!

### Common Pitfall: Duplicate [Resolve] Sections

If your `/etc/systemd/resolved.conf` has duplicate `[Resolve]` sections, the configuration breaks:

```ini
[Resolve]
LLMNR=false
[Resolve]  # WRONG! Duplicate section
DNS=100.117.76.42
```

In NixOS, the `extraConfig` already gets wrapped in a `[Resolve]` section, so don't include it:

❌ **Wrong:**
```nix
extraConfig = ''
  [Resolve]
  DNS=100.117.76.42
'';
```

✅ **Right:**
```nix
extraConfig = ''
  DNS=100.117.76.42
'';
```

## Verification

### Check DNS Configuration

```bash
# Check global resolver - should show AdGuard as primary
resolvectl status | head -10
# Should show DNS Servers: 100.117.76.42

# Verify split DNS for Tailscale
resolvectl status tailscale0 | head -20
# Should show DNS Domain: tail0b5947.ts.net and DNS Servers: 100.100.100.100

# Test Tailscale MagicDNS
dig ben.tail0b5947.ts.net  # Should resolve to Tailscale IP

# Test regular DNS goes through AdGuard
dig example.com  # Should resolve normally

# Test AdGuard blocking
dig youtube.com  # Should return 0.0.0.0 if blocked in AdGuard
```

### Check AdGuard is Working

1. Access AdGuard web interface: http://100.117.76.42:3000
2. Check query logs to see requests from chris (100.68.36.35)
3. Configure blocking rules (e.g., block YouTube)
4. Test blocking works: `dig youtube.com` should return `0.0.0.0`

### Test Fallback

```bash
# Stop AdGuard on zeze
ssh zeze "sudo systemctl stop adguardhome"

# DNS should still work via fallbacks (Cloudflare/Google)
dig example.com  # Should still resolve

# Restart AdGuard
ssh zeze "sudo systemctl start adguardhome"
```

## Troubleshooting

### AdGuard Blocking Not Working After Reboot

**Symptom:** YouTube accessible after reboot despite AdGuard blocking it

**Cause:** systemd-resolved using Cloudflare (1.1.1.1) instead of AdGuard

**Solution:** Check your `resolved.conf`:
```bash
cat /etc/systemd/resolved.conf
```

Make sure:
1. Only ONE `[Resolve]` section exists
2. Only AdGuard in `DNS=` line
3. Other servers only in `FallbackDNS=`

Then restart systemd-resolved:
```bash
sudo systemctl restart systemd-resolved
```

### DNS Not Resolving At All

```bash
# Check systemd-resolved is running
systemctl status systemd-resolved

# Check /etc/resolv.conf points to systemd-resolved
ls -la /etc/resolv.conf
# Should be symlink to ../run/systemd/resolve/stub-resolv.conf

# Check configuration
cat /etc/systemd/resolved.conf

# Test direct query to AdGuard
dig example.com @100.117.76.42
```

### Tailscale Names Not Resolving

```bash
# Check Tailscale is connected
tailscale status

# Check split DNS is configured
resolvectl status tailscale0
# Should show DNS Domain including tail*.ts.net

# Test direct query to MagicDNS
dig ben.tail0b5947.ts.net @100.100.100.100
```

## Important Notes

### Tailscale Admin Console Settings

In the Tailscale admin DNS page:
- **DO NOT** set "Global nameservers" (this would make Tailscale handle ALL DNS)
- **Keep MagicDNS enabled** for `.ts.net` resolution
- With `--accept-dns=true` and no global nameservers, Tailscale only adds split-DNS for tailnet domains

### How DNS Resolution Works

1. All queries go to systemd-resolved (127.0.0.53)
2. systemd-resolved checks the domain:
   - Tailscale domains (`.ts.net`) → Tailscale MagicDNS (100.100.100.100)
   - Everything else → AdGuard (100.117.76.42)
3. If AdGuard is down → Fallback DNS servers (Cloudflare/Google)

### Why We Don't Need Dispatcher Scripts

Initially, we thought NetworkManager dispatcher scripts were needed to force connections to ignore DHCP DNS. However, with proper systemd-resolved configuration:

- `Domains=~.` tells systemd-resolved to use global DNS for ALL domains
- Even if interfaces get DNS from DHCP, global DNS takes precedence
- The dispatcher scripts were unnecessary complexity!

The real fix was:
1. Having ONLY AdGuard in `DNS=` (not multiple servers)
2. Using `Domains=~.` to route everything through global DNS
3. Ensuring no duplicate `[Resolve]` sections in the config

### Benefits of This Setup

- **Ad blocking** for all DNS queries (configured in AdGuard)
- **Privacy** - DNS queries go through your Tailnet when possible
- **Reliability** - Automatic fallback to public DNS if AdGuard is offline
- **Simplicity** - No complex scripts or workarounds needed
- **MagicDNS** - Seamless Tailscale hostname resolution
- **Persistence** - Configuration survives reboots