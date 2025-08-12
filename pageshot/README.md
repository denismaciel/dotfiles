# Pageshot - Browser Screenshot Tool

A lean, Nix-first CLI tool for taking full-page browser screenshots using headless Chromium. Built with Go and chromedp for reliability and performance.

## Features

- **Single binary**: Statically compiled Go application
- **Nix-reproducible**: Fully pinned dependencies including Chromium and fonts
- **Full-page screenshots**: Automatically captures entire page content
- **Multiple formats**: PNG, JPEG, and PDF output support
- **Progressive scrolling**: Trigger lazy-loaded images
- **Configurable waiting**: Load, DOM ready, or network idle strategies
- **Custom headers**: Support for authentication and cookies

## Quick Start

### Using Nix (Recommended)

```bash
# Run directly from the flake
nix run . -- --out=screenshot.png https://example.com

# Install locally
nix build .
./result/bin/pageshot --out=screenshot.png https://example.com
```

### Development

```bash
# Enter development shell
nix develop

# Build manually
go build -o pageshot

# Set Chrome path for local development
export CHROME_PATH=$(which chromium)
./pageshot https://example.com
```

## Usage

```
pageshot [options] URL

Options:
  --out path.png               Output file path (default: screenshot.png)
  --wait load|dom|idle         Wait strategy (default: idle)
  --timeout ms                 Timeout in milliseconds (default: 30000)
  --viewport 1280x800          Initial viewport (default: 1280x800)
  --dpr 1..3                   Device pixel ratio (default: 2)
  --full                       Full-page screenshot (default: true)
  --scroll                     Progressive scroll for lazy images
  --delay ms                   Extra delay before screenshot
  --user-agent "..."           Override user agent
  --header "Name: Value"       HTTP headers (repeatable)
  --jpeg --quality 0..100      JPEG output with quality
  --pdf                        PDF output instead of image
  --selector "#main"           Wait for specific element
  --quiet                      Suppress info logs
```

## Examples

### Basic Screenshot
```bash
nix run . -- https://github.com
```

### High-DPR Full Page with Scrolling
```bash
nix run . -- --dpr=2 --scroll --out=hn.png https://news.ycombinator.com
```

### PDF Export
```bash
nix run . -- --pdf --out=page.pdf https://example.com
```

### Authenticated Page
```bash
nix run . -- --header "Authorization: Bearer token123" \
  --wait=load \
  --delay=2000 \
  https://api.example.com/dashboard
```

### Custom Viewport and Format
```bash
nix run . -- --viewport=375x667 \
  --jpeg \
  --quality=85 \
  --out=mobile.jpg \
  https://mobile-site.com
```

## Wait Strategies

- **`idle`** (default): Wait for network idle (~500ms no requests)
- **`load`**: Wait for page load event
- **`dom`**: Wait for DOM content loaded

For single-page applications or sites with continuous requests, use `--wait=load --delay=1000`.

## Architecture

- **Go + chromedp**: Direct Chrome DevTools Protocol control
- **Nix flake**: Reproducible builds with pinned Chromium and fonts
- **Wrapped binary**: Proper environment setup for headless execution
- **Font support**: Includes Noto fonts to prevent rendering issues

## Exit Codes

- `0`: Success
- `1`: Error (navigation timeout, invalid URL, file write errors, etc.)

## Requirements

- Nix with flakes enabled
- Linux or macOS (x86_64/aarch64)

## Troubleshooting

### Screenshots timeout
- Increase `--timeout` for slow-loading pages
- Try `--wait=load` instead of `idle` for SPAs
- Add `--delay` for pages that need time to settle

### Missing fonts/rendering issues
The Nix wrapper automatically includes comprehensive font support, but if you see rendering issues, the fonts are available in the environment.

### Headless mode issues
The tool automatically configures Chromium for headless operation with proper sandbox settings for most environments.