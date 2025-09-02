# KOReader Setup with Calibre-Web & Sync Server

## Services Running on ben

### 1. Calibre-Web (OPDS Library)
- **URL**: https://ben.tail0b5947.ts.net
- **OPDS**: https://ben.tail0b5947.ts.net/opds
- **Default login**: admin / admin123 (CHANGE THIS!)
- **Library location**: `/srv/books/calibre/`

### 2. KOReader Sync Server (Reading Progress)
- **URL**: https://ben.tail0b5947.ts.net:7200
- **Port**: 7200
- **Protocol**: HTTPS (self-signed cert)
- **Running as**: Docker container

## Phone Setup (KOReader)

### 1. Connect to OPDS Library
1. Install Tailscale app on phone and join your tailnet
2. In KOReader: Tools → OPDS catalog → Add new catalog
3. Enter:
   - Name: Home Library
   - URL: `https://ben.tail0b5947.ts.net/opds`
   - Username: admin (or your username)
   - Password: (your password)

### 2. Configure Sync Server
1. In KOReader: Tools → Progress sync → Settings
2. Enter:
   - Server: `ben.tail0b5947.ts.net`
   - Port: `7200`
   - Username: (any username you want)
   - Password: (any password you want)
3. Enable: Auto sync

The sync server will auto-register new users on first use.

## Managing the Services

### Check service status
```bash
ssh ben "systemctl status calibre-web"
ssh ben "sudo docker ps | grep kosync"
```

### Restart services
```bash
ssh ben "sudo systemctl restart calibre-web"
ssh ben "sudo docker restart kosync"
```

### View logs
```bash
ssh ben "journalctl -u calibre-web -f"
ssh ben "sudo docker logs kosync -f"
```

## Adding Books

### Option 1: Web Upload
1. Go to https://ben.tail0b5947.ts.net
2. Click "Upload" button
3. Select your ebook files

### Option 2: Direct Copy
```bash
scp book.epub ben:/srv/books/calibre/
ssh ben "sudo chown calibre-web:media /srv/books/calibre/book.epub"
```

### Option 3: Use Desktop Calibre
Mount the library via SSHFS or NFS and manage with desktop Calibre.

## Troubleshooting

### KOSync not working
The official KOReader sync server expects a specific API format. If sync isn't working:
1. Check container is running: `ssh ben "sudo docker ps | grep kosync"`
2. Test connection: `curl -k https://ben.tail0b5947.ts.net:7200`
3. In KOReader, try using HTTP instead of HTTPS if issues persist

### Calibre-Web issues
1. Check service: `ssh ben "systemctl status calibre-web"`
2. Verify library: `ssh ben "ls -la /srv/books/calibre/"`
3. Check permissions: Files should be owned by `calibre-web:media`