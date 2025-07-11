# Brother HL-1110 Printer Setup on NixOS

This document describes how to set up a Brother HL-1110 USB printer on a NixOS system (sam) and enable network printing from other machines.

## 1. NixOS Configuration

Add the following to your NixOS configuration file (`/hosts/sam/configuration.nix`):

```nix
# Enable CUPS to print documents.
services.printing.enable = true;
services.printing.browsing = true;
services.printing.defaultShared = true;
services.printing.listenAddresses = [ "*:631" ];
services.printing.allowFrom = [ "all" ];
services.printing.openFirewall = true;
services.printing.drivers = with pkgs; [
  brlaser
  brgenml1cupswrapper
  brgenml1lpr
];

# Add usbutils for lsusb command
environment.systemPackages = with pkgs; [
  neovim
  git
  usbutils
];
```

## 2. Rebuild NixOS Configuration

```bash
mise run rebuild-sam
# or
nixos-rebuild switch --flake ~/dotfiles#sam --target-host sam
```

## 3. Verify USB Printer Detection

```bash
# Check if printer is detected
lsusb | grep Brother
# Output: Bus 001 Device 006: ID 04f9:0054 Brother Industries, Ltd HL-1110 series

# Check available printer URIs
lpinfo -v | grep Brother
# Output: direct usb://Brother/HL-1110%20series?serial=D0N609455
```

## 4. Add Printer to CUPS

```bash
# Find the appropriate driver
lpinfo -m | grep -i 'brother.*hl-1110'
# Output: drv:///brlaser.drv/br1110.ppd Brother HL-1110 series, using brlaser

# Add the printer
sudo lpadmin -p Brother-HL-1110 -E -v "usb://Brother/HL-1110%20series?serial=D0N609455" -m drv:///brlaser.drv/br1110.ppd

# Set as default printer
sudo lpadmin -d Brother-HL-1110
```

## 5. Enable Network Printer Sharing

```bash
# Enable CUPS sharing features
sudo cupsctl --share-printers --remote-any --remote-admin

# Enable sharing for the specific printer
sudo lpadmin -p Brother-HL-1110 -o printer-is-shared=true

# Restart CUPS
sudo systemctl restart cups
```

## 6. Test Local Printing

```bash
# Test print directly on sam
echo "Test print" | lp -d Brother-HL-1110
```

## 7. Configure Network Printing from Other Machines

On the client machine (e.g., chris):

```bash
# Get the server's IP address
getent hosts sam
# Output: 100.90.43.65 sam.tail0b5947.ts.net

# Add the network printer
sudo lpadmin -p Brother-HL-1110-sam -E -v ipp://100.90.43.65:631/printers/Brother-HL-1110 -m everywhere

# Test network printing
echo "Test from client" | lp -d Brother-HL-1110-sam
```

## Troubleshooting

### Check printer status
```bash
lpstat -p -d
```

### Check print queue
```bash
lpstat -o
```

### Cancel stuck print jobs
```bash
cancel -a  # Cancel all jobs
cancel <job-id>  # Cancel specific job
```

### View CUPS web interface
- Local: http://localhost:631
- Network: http://sam:631 or http://sam.local:631

### Common Issues

1. **Jobs stuck in queue**: Usually indicates the printer isn't properly shared or there's a network connectivity issue
2. **"No such file or directory" for lsusb**: Make sure `usbutils` is installed in your NixOS configuration
3. **IPP Everywhere driver error**: Use the specific Brother driver (brlaser) instead of the generic IPP Everywhere driver

## Notes

- The Brother HL-1110 uses the open-source `brlaser` driver which works well with this model
- CUPS printer drivers are deprecated and will be replaced by IPP Everywhere in future versions
- Make sure firewall allows port 631 for CUPS (handled by `services.printing.openFirewall = true`)