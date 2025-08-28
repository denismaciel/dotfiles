# Design: Integrate cachix/git-hooks.nix into this repo

## Goals

- Reproducible, fast, Nix-pinned Git hooks for local development and CI.
- Replace or complement the existing Python `pre-commit` setup with a purely Nix-based approach.
- Align hooks with tools already configured in this repo (ruff, stylua, statix, etc.).

## Non‑Goals

- Change formatting/lint preferences beyond wiring existing tools.
- Introduce nonessential tools unrelated to this codebase.

## Current State

- Nix flake repository with NixOS configs; no root `devShell` today.
- Tooling configs present: `ruff.toml`, `stylua.toml`, `statix.toml`, `biome.json`, `.pre-commit-config.yaml`.
- `flake.lock` already contains references to `cachix/git-hooks.nix` but it is not wired in `flake.nix`.

## Approach Overview

- Add a `git-hooks` flake input and use `git-hooks.lib.<system>.run` to declare hooks.
- Expose the hooks as `checks` so `nix flake check` runs them in CI.
- Create a root `devShell` that installs/updates `.git/hooks` automatically via the returned `shellHook`.
- Start with a minimal, high-value hook set that mirrors current configs:
  - Nix: `alejandra` (or `nixfmt-rfc-style`), `statix`, `deadnix`.
  - Shell: `shfmt`, `shellcheck`.
  - Markdown: `markdownlint-cli` (or `mdformat`).
  - Lua: `stylua`.
  - Python: `ruff` (format+lint); optionally `mypy` later.
  - Secrets: `ripsecrets` (fast) or `trufflehog` (deeper, slower) — choose one.
- Migrate from Python `pre-commit` gradually; keep `.pre-commit-config.yaml` during rollout.

## Proposed Flake Changes (root `flake.nix`)

Add the `git-hooks` input:

```nix
inputs.git-hooks.url = "github:cachix/git-hooks.nix";
```

Wire hooks into `checks` and expose a `devShell` that auto-installs Git hooks:

```nix
{
  outputs = inputs @ { self, nixpkgs, git-hooks, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (s: f s);
    in {
      checks = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          hooks = git-hooks.lib.${system}.run {
            src = ./.; # repo root
            hooks = {
              # Nix tooling
              alejandra.enable = true;       # or: nixfmt-rfc-style.enable = true;
              statix.enable = true;
              deadnix.enable = true;

              # Shell scripting
              shfmt.enable = true;
              shellcheck.enable = true;

              # Markdown
              markdownlint-cli.enable = true;  # or mdformat.enable = true;

              # Lua
              stylua.enable = true;

              # Python
              ruff = {
                enable = true;
                settings = {
                  # Example: fix in-place when possible
                  args = ["--fix"]; 
                };
              };

              # Secrets (pick one)
              ripsecrets.enable = true; # fast; or trufflehog.enable = true;
            };

            # Optional: restrict what files each hook sees to avoid noise
            # files = "(\\.nix$|\\.md$|\\.sh$|\\.lua$|\\.py$)";
          };
        in {
          pre-commit = hooks; # Enables `nix build .#checks.${system}.pre-commit`
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          preCommit = self.checks.${system}.pre-commit;
        in {
          default = pkgs.mkShell {
            # Tools needed by hooks become available to developers
            packages = preCommit.packages or [];

            # Installs .git/hooks and keeps them updated when entering the shell
            shellHook = preCommit.shellHook;
          };
        }
      );
    };
}
```

Notes:

- `alejandra` vs `nixfmt-rfc-style`: pick one formatter to avoid conflicts. This repo currently has no enforced Nix formatter; `alejandra` is safe default.
- The `settings.args` pattern (e.g. for `ruff`) is supported by many hooks to pass CLI flags.
- You can target subsets via `files` regex to speed up runs in large repos.

## Developer Workflow

- Run `nix develop` at the repo root:
  - Installs/updates `.git/hooks/pre-commit` automatically.
  - Ensures all hook tools are present in PATH.
- Commit as usual; hooks run quickly from the Nix store and auto-fix many issues.
- Run hooks manually in CI/local as a check:
  - `nix build .#checks.$(nix eval --raw --impure --expr builtins.currentSystem).pre-commit`
  - or `nix flake check` if you wire it under `checks` only.

## CI Integration (GitHub Actions example)

```yaml
name: Pre-commit
on: [pull_request, push]
jobs:
  checks:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v30
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      - name: Run pre-commit hooks via Nix
        run: nix build .#checks.x86_64-linux.pre-commit
```

Adjust the system string to match the CI runner if needed.

## Migration Plan from `.pre-commit-config.yaml`

1. Phase 1 (dual-run):
   - Keep `.pre-commit-config.yaml` for now.
   - Introduce Nix hooks via `git-hooks.nix` in the `devShell` and `checks`.
   - Ensure results match (formatting/linting) for a few PRs.

2. Phase 2 (switch):
   - Remove Python `pre-commit` from the Makefile and docs.
   - Delete `.pre-commit-config.yaml` once parity is confirmed.

## Risks & Mitigations

- Tool duplication/conflicts: enable a single formatter per language.
- Performance on first run: tools build once and then are cached; subsequent runs are fast.
- Flake input drift: automate `nix flake update` or pin to known-good revisions.

## Open Questions

- Formatter choice for Nix: `alejandra` vs `nixfmt-rfc-style`.
- Secrets scanning depth: `ripsecrets` (fast) vs `trufflehog` (deep).
- Python type checking in hooks: do we want `mypy`/`pyright` on commit or only in CI?

## Next Steps

- Confirm formatter choices and secrets policy.
- I can wire the `git-hooks` input and add the `checks`/`devShells` stanzas to root `flake.nix` once decisions are made.

