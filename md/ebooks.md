Perfect—let’s stand up **Calibre-Web on your NixOS home server** and hook your **phone (KOReader)** to it over **Tailscale**. We’ll skip Nextcloud and Kindle for now.

# 1) NixOS home-server config

Create a Calibre library directory (where `metadata.db` lives) and enable Calibre-Web + Tailscale. Example module:

```nix
{ config, pkgs, ... }:
{
  # --- Tailscale ---
  services.tailscale.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Optional, ensures ebook-convert is around if you want conversions
  environment.systemPackages = [ pkgs.calibre ];

  # --- Calibre-Web (library & OPDS) ---
  services.calibre-web = {
    enable = true;
    group = "media";  # or a group that owns your /srv/books/calibre
    listen = { ip = "127.0.0.1"; port = 8083; };
    options = {
      calibreLibrary = "/srv/books/calibre";  # must contain metadata.db
      enableBookUploading = true;             # upload via web UI
      enableBookConversion = true;            # use ebook-convert
    };
  };
}
```

> Notes
> • The NixOS module exposes the `calibreLibrary`, `enableBookUploading`, and `enableBookConversion` options (and more). ([MyNixOS][1])
> • Calibre-Web serves OPDS at `http://<host>:8083/opds`. We’ll publish that safely via Tailscale next. ([GitHub][2])

Apply config, then publish private HTTPS inside your tailnet:

```bash
# Calibre-Web on https://<server>.ts.net (443)
tailscale serve --https=443  http://127.0.0.1:8083
```

This gives you a valid TLS cert on your `*.ts.net` name inside the tailnet (no public exposure). ([Tailscale][3])

**First run:**

* Visit `https://<server>.ts.net` (from any device on your tailnet).
* Log in; on vanilla Calibre-Web the default is `admin` / `admin123` → change it immediately. ([GitHub][2])
* Point it to your library directory if prompted. (You can create/manage the library with desktop Calibre; Calibre-Web just reads it.)

# 2) Put some books in the library

On your workstation (not the server), manage books with **Calibre** and set its library path to `/srv/books/calibre` (via NFS/SMB/SSHFS) *or* rsync new books into that directory so `metadata.db` stays authoritative. Calibre-Web will show them automatically. (General Calibre server/OPDS patterns use the `/opds` path.) ([manual.calibre-ebook.com][4], [MobileRead][5])

# 3) Phone setup (KOReader + OPDS)

1. **Join your tailnet** on the phone (install the Tailscale app, sign in).
2. **Install KOReader** (Android builds documented in KOReader’s guide). ([koreader.rocks][6])
3. In KOReader, add your OPDS catalog:

   * Open KOReader → top bar menu → **OPDS catalog** → **+ Add** →
     URL: `https://<server>.ts.net/opds` → save. ([koreader.rocks][7], [Reddit][8])
4. Browse your shelves/authors, tap a book to **Download**, then open and read. (OPDS via Calibre-Web is the intended way; the path is `/opds`.) ([GitHub][2], [Thejesh GN ⏚ ತೇಜೇಶ್ ಜಿ.ಎನ್][9])

# 4) Quick checks & common gotchas

* **OPDS 404 or “not an OPDS”** → double-check the exact path `/opds` and that you’re hitting the Tailscale URL (not localhost). ([GitHub][2])
* **Library empty** → ensure `/srv/books/calibre/metadata.db` exists (created by desktop Calibre) and Calibre-Web points to that folder.
* **Conversions** → if you enable conversions, `ebook-convert` must be present (we added `pkgs.calibre`). ([MyNixOS][1])
* **HTTPS** via Serve requires HTTPS enabled in your tailnet; the Tailscale docs walk through it. ([Tailscale][10])

---

If you want, I can tailor the NixOS snippet to your exact paths/users and add a tiny systemd tmpfiles rule to create `/srv/books/calibre` with the right ownership. When you’re ready to add the **Kindle**, we’ll layer in **KOReader + self-hosted progress sync** so your last-page-read follows you between devices.

[1]: https://mynixos.com/nixpkgs/options/services.calibre-web.options?utm_source=chatgpt.com "services.calibre-web.options"
[2]: https://github.com/janeczku/calibre-web?utm_source=chatgpt.com "janeczku/calibre-web: :books"
[3]: https://tailscale.com/kb/1242/tailscale-serve?utm_source=chatgpt.com "tailscale serve command"
[4]: https://manual.calibre-ebook.com/generated/en/calibre-server.html?utm_source=chatgpt.com "calibre-server — calibre 8.9.0 documentation"
[5]: https://www.mobileread.com/forums/showthread.php?t=346188&utm_source=chatgpt.com "calibre OPDS server"
[6]: https://koreader.rocks/user_guide/?utm_source=chatgpt.com "KOReader User Guide"
[7]: https://koreader.rocks/doc/topics/README.md.html?utm_source=chatgpt.com "KOReader Documentation"
[8]: https://www.reddit.com/r/koreader/comments/1fj8ntb/custom_opds/?utm_source=chatgpt.com "Custom OPDS : r/koreader"
[9]: https://thejeshgn.com/2024/01/23/hosting-books-at-home-using-calibre-web/?utm_source=chatgpt.com "Hosting Books at Home using Calibre Web"
[10]: https://tailscale.com/kb/1312/serve?utm_source=chatgpt.com "Tailscale Serve"
