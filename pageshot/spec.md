Here’s a lean, Nix-first architecture that gives you a single `nix run` CLI which opens a real headless browser and outputs a **full-page** screenshot—no ad-hoc installs, no Playwright downloads, fully pinned & reproducible.

# High-level idea

* **CLI app** (Go) drives **Chromium** via the **Chrome DevTools Protocol (CDP)** using `chromedp`.
* Nix **flake** provides everything: the compiled binary, a pinned `chromium` runtime, and fonts (so text doesn’t render as tofu).
* A tiny **wrapper** ensures the binary uses the Nix-store Chromium and runs fully headless/sandboxed.
* Result: `nix run . -- https://example.com --out=page.png` works on any machine with Nix.

---

# Components & responsibilities

## 1) CLI (Go + chromedp)

* **Why Go/chromedp?**

  * No extra browser download step (unlike stock Playwright/Puppeteer).
  * Produces a single static binary.
  * Direct CDP control = precise full-page capture and robust waiting logic.
* **Responsibilities**

  * Parse flags and normalize the URL.
  * Launch a **headless Chromium** process (path injected by wrapper), set viewport/device scale factor (DPR).
  * Navigate, **wait** for readiness (configurable: `load`, `domcontentloaded`, `networkidle`).
  * Optional **progressive scroll** to bottom to trigger lazy load.
  * Compute page dimensions (`document.scrollingElement.scrollHeight`) and do a **full-page** screenshot at DPR.
  * Save `PNG` (default) or `JPEG` (quality flag). Optional `--pdf`.
  * Exit codes & terse logs for scripting.

**MVP flags**

```
pageshot URL
  --out path.png               # default: ./screenshot.png
  --wait load|dom|idle         # default: idle (network idle)
  --timeout ms                 # default: 30000
  --viewport 1280x800          # initial viewport, default 1280x800
  --dpr 1..3                   # device scale factor, default 2
  --full                       # full-page (default true)
  --scroll                     # progressive scroll before shot (for lazy images)
  --delay ms                   # extra settle delay before shot
  --user-agent "..."           # override UA if needed
  --header "Name: Value"       # repeatable; simple auth/cookies via headers
  --jpeg --quality 0..100      # alternative output format
  --pdf                        # export as PDF instead of image
  --selector "#main"           # optional: wait for selector before shooting
```

**Flow**

1. Validate URL; set timeouts.
2. Start Chromium with `--headless=new`, ephemeral user-data-dir, **sandbox ON** (no `--no-sandbox`).
3. Set viewport & DPR.
4. `Navigate` → `Wait` (per flag) → optional `scroll` (incremental to bottom).
5. Compute full height, take full-page screenshot.
6. Write file, cleanly shutdown.

## 2) Browser runtime (Chromium from nixpkgs)

* Use `pkgs.chromium` (pinned by flake).
* Include fonts to avoid missing glyphs:

  * `noto-fonts`, `noto-fonts-cjk`, `noto-fonts-emoji`.
* Optionally include `fonts.conf` shim to ensure Chromium finds them in the Nix store.

## 3) Nix flake

* **packages.default**: the wrapped CLI.
* **apps.default**: runs the wrapper so you can `nix run`.
* **devShell**: for hacking (Go toolchain, `dlv`, etc.).

**Build shape**

* `buildGoModule` to compile `pageshot`.
* `makeWrapper` to produce `pageshot` script that:

  * Exposes `${pkgs.chromium}/bin/chromium` via `PATH` and/or sets `CHROME_PATH`.
  * Exposes font directories via `FONTCONFIG_FILE`/`XDG_DATA_DIRS` if needed.
* Closure includes `chromium` + fonts, so the runtime has everything (no network fetches).

## 4) Wrapper & sandboxing

* Wrapper launches the compiled binary with the right env.
* The binary then spawns Chromium with:

  * `--headless=new`
  * `--disable-gpu` (harmless headless)
  * `--no-first-run --no-default-browser-check`
  * `--user-data-dir` pointing to a temp dir
* **Keep the sandbox on** for safety (don’t pass `--no-sandbox` unless you must run as root in a constrained CI).

---

# Why this design (and not …)

* **vs. Playwright/Puppeteer**: both are great, but by default they download browsers outside Nix. You *can* make them Nix-pure with extra work (pinning `playwright-driver` and wiring envs), but Go+chromedp stays minimal and avoids Node packaging complexity.
* **vs. wkhtmltoimage**: simpler, tiny closure—but uses old WebKit; many modern, JS-heavy sites render incorrectly. Chromium headless is much more accurate.

---

# Operational details

## Waiting strategy (reliability)

* Default `--wait=idle` means: *no network for \~500ms*. Good general proxy for “page settled.”
* Some SPAs trickle requests forever; switch to `--wait=load` + `--delay 1000` to get a predictable capture.
* `--selector` ensures a specific element is present before shooting (useful for A/B, consent banners, etc.).

## Full-page correctness

* Compute `scrollHeight` (not `clientHeight`) from `document.scrollingElement`.
* For lazy images: `--scroll` runs a loop (`window.scrollBy`) with small waits to trigger intersection observers, then scrolls back to top.

## Image quality

* DPR via `--dpr` (default 2) yields crisp images on HiDPI.
* PNG for fidelity; JPEG+quality for smaller files.
* `--pdf` uses Chromium’s native PDF print—useful for archival.

## Error handling & exit codes

* Non-zero on:

  * navigation timeout
  * invalid URL
  * file write errors
  * Chromium launch failures
* Logs to stderr; `--quiet` to suppress info logs in scripts.

---

# Nix UX

* **Run**:
  `nix run . -- https://example.com --out=shot.png --wait=idle --dpr=2 --scroll`
* **Build** (for a reusable binary/wrapper in `result/bin`):
  `nix build .#pageshot`
* **Hack**:
  `nix develop` → iterate on Go code.

---

# Extensible knobs (future, still simple)

* `--cookie-file cookies.json` (array of `{name, value, domain, path}`) for authenticated captures.
* `--click "#accept"` to dismiss GDPR banners.
* `--proxy http://user:pass@host:port` if you need locality testing.
* `--trace trace.json` to export a DevTools performance trace when debugging slow pages.
* `--concurrency N` to batch multiple URLs (spawn per-URL browser to isolate).

---

# Testing plan (quick & meaningful)

1. **Static HTML**: verify dimensions and edges aren’t clipped.
2. **Lazy images**: ensure `--scroll` loads below-the-fold.
3. **Infinite loaders**: confirm `--wait=load --delay=1500` stabilizes output.
4. **I18N**: render CJK + emoji; verify fonts present.
5. **Auth header**: protected page with simple `--header "Authorization: Bearer …"`.

---

# Risks & mitigations

* **Heavy closure size** (Chromium + fonts): expected; mitigated by Nix caching. You asked for “no installs”—this is the tradeoff for correctness.
* **Sites blocking headless**: allow `--user-agent` and optional `--stealth` tweaks (CDP can mask some signals).
* **GPU/driver quirks**: headless + software rendering avoids most issues.

---

If you want, I can turn this into a ready-to-run flake (Go code + `flake.nix` + wrapper) so you can `nix run` immediately.
