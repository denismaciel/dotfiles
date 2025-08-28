# NixOS “chris” Host — Prioritized Improvement Report

The list below is ordered by importance (highest → lowest). Each item explains what to change, why it matters, and how to approach it. No code is included — just guidance.

1) Pin nixpkgs to a stable source
- What: Stop tracking `nixpkgs` master; pin to a stable channel or specific commit.
- Why: Master changes frequently and can break builds unexpectedly. A stable pin improves reproducibility and reduces surprises.
- How: Point `inputs.nixpkgs` to `nixos-24.05` (or a commit SHA) and update the lock file. Keep a clear cadence for updates.

2) Remove hard-coded architecture and paths
- What: Eliminate `x86_64-linux` and absolute paths (e.g., NH flake path) in the chris config and flake plumbing.
- Why: Hard-coding blocks portability (remote builds, different machines/arches) and makes configs brittle.
- How: Use `${pkgs.system}`/`${final.system}` or pass `system` via `specialArgs`. For NH, avoid absolute paths; prefer self-relative flake references.

3) Unify Polybar/Awesome config templating
- What: Use a single approach to produce processed config files (either entirely via the system module or entirely via HM), not both.
- Why: Dual mechanisms (flake-time processing and module-time processing) duplicate logic and can drift.
- How: Centralize variable substitution in one module and pass the resulting paths through well-defined options/args for Home Manager to consume.

4) Replace non-standard `replaceVars`
- What: Avoid `pkgs.replaceVars` (non-standard) for config file templating.
- Why: It’s unclear/fragile across nixpkgs revisions. Using standard primitives is more reliable.
- How: Prefer `substituteAll`-style derivations or string substitution helpers provided by nixpkgs/lib for predictable, upstream-supported behavior.

5) Consolidate Nix settings sources
- What: Don’t set the same Nix options in both the flake’s `nixConfig` and `stow/nix/nix.conf`.
- Why: Duplicate sources can conflict and cause confusion about which one “wins”.
- How: Pick one canonical source (typically the flake’s `nixConfig`) and remove the duplicate.

6) Simplify SSH agent strategy
- What: Choose one agent: OpenSSH agent, gpg-agent (with SSH support), or gnome-keyring’s GCR; disable the others.
- Why: Multiple agents create conflicts (e.g., too many keys loaded, unpredictable auth prompts).
- How: Decide on your preferred agent. If using 1Password, integrate its SSH agent and disable the rest. Otherwise, standardize on OpenSSH or gpg-agent and ensure others are off.

7) Enable Nix GC and store optimization
- What: Turn on automatic garbage collection and store optimization.
- Why: Keeps the store lean and improves performance over time.
- How: Configure periodic `nix.gc` (weekly is fine) and `nix.settings.auto-optimise-store = true`.

8) Parameterize Tailscale details
- What: Avoid hard-coded exit-node IP and move tailnet-specific details to variables/secrets.
- Why: Hard-coding operational values is brittle and leaks environment assumptions.
- How: Make exit-node choice configurable, and use a secret-backed auth strategy (e.g., sops-nix for auth keys), or set via controlled runtime commands.

9) Remove `targets.genericLinux` on NixOS
- What: Don’t enable Home Manager’s `targets.genericLinux` on a NixOS host.
- Why: It’s intended for non-NixOS systems and can add unnecessary services/paths.
- How: Remove that option from the chris HM config.

10) Avoid double-installing Neovim
- What: Don’t install `neovim` at the system level if HM already provides a nightly Neovim.
- Why: Reduces closure size and ambiguity over which binary you run.
- How: Keep the nightly via HM (or use an overlay) and drop the system-level package, or standardize on one Neovim source.

11) Prefer user packages in HM over system packages
- What: Move user-facing tools (file manager, CLI tools, editors) to Home Manager where practical.
- Why: Speeds up system rebuilds, isolates user environment, and reduces global closures.
- How: Shift packages from `environment.systemPackages` to `home.packages` when they’re user-only.

12) Complete PipeWire setup explicitly
- What: Explicitly enable ALSA and 32-bit support and wireplumber for PipeWire if needed.
- Why: Improves compatibility and avoids subtle audio issues, especially for desktop apps.
- How: Add the ALSA toggles and ensure the session manager is enabled; keep it consistent with your NixOS release best practices.

13) Integrate DNS with systemd-resolved for Tailscale
- What: Use systemd-resolved with NetworkManager and allow Tailscale to control DNS.
- Why: Ensures tailnet DNS works reliably and avoids conflicts with static nameserver overrides.
- How: Enable resolved, configure NM to use it, and allow Tailscale to manage DNS (`useTailnetDNS`).

14) Revisit passwordless sudo
- What: Confirm that `security.sudo.wheelNeedsPassword = false` is acceptable for this host.
- Why: It’s a convenience-versus-security tradeoff; useful locally, risky on shared or reachable machines.
- How: Keep as-is if you’re comfortable, or scope passwordless sudo to specific commands/groups.

15) Centralize font choices
- What: Avoid defining fonts in multiple places (Stylix vs HM vs system) unless necessary.
- Why: Reduces duplication and closure size; keeps look-and-feel consistent.
- How: Let Stylix be the single source, and only add extra fonts for specific apps.

16) Prune unused flake inputs
- What: Remove inputs you don’t consume for chris (or document why they’re retained globally).
- Why: Smaller evaluation surface and less cognitive overhead.
- How: If an input isn’t used in any host or module, remove it. If it’s used elsewhere, leave it but document intent.

17) Prefer unfree predicates over blanket allowUnfree
- What: Use `allowUnfreePredicate` consistently instead of both a blanket `allowUnfree = true` and a predicate.
- Why: Keeps the set of unfree packages explicit and avoids accidental additions.
- How: Consolidate to a single predicate that lists the unfree packages you actually need.

18) Update deprecated language server
- What: Replace `sumneko-lua-language-server` with `lua-language-server`.
- Why: The package was renamed/upstreamed; the new name avoids future breakage.
- How: Swap the package reference in `home.packages`.

19) Prefer dynamic user/home discovery
- What: Avoid repeating `home.username` and `home.homeDirectory` if they can be derived or passed once.
- Why: Reduces duplication and chances of drift between NixOS and HM.
- How: Pass relevant values via `specialArgs` or derive them where practical.

20) Consider `hardware.graphics` (24.05+) convenience module
- What: Use the consolidated graphics module if on a recent NixOS release.
- Why: Simplifies OpenGL/graphics configuration with saner defaults.
- How: Enable the module and remove scattered legacy graphics toggles as applicable.

21) Streamline service starts under X11
- What: For X11 session setup (e.g., wallpaper via `feh`), keep all such user services consistently in HM.
- Why: Clear ownership of user session responsibilities and easier troubleshooting.
- How: Ensure related session services start via `graphical-session.target` in HM.

22) Add routine policy checks
- What: Lint and static-check Nix regularly (you already install `alejandra` and `statix`). Consider adding `deadnix` for unused attr detection.
- Why: Helps catch drift, unused code, and formatting issues early.
- How: Run these locally or wire them into your workflow (pre-commit or CI).

23) Review printing and other rarely used services
- What: Disable `services.printing` and any other infrequently used services on this host.
- Why: Reduce attack surface and background resource usage.
- How: Remove or gate them behind host-specific toggles.

24) Consider secrets management for future additions
- What: Use sops-nix (or similar) for any future secrets (e.g., Tailscale auth key, API tokens).
- Why: Keeps secrets out of the repo and automates provisioning.
- How: Introduce sops-nix, define secrets per-host, and reference them in system/HM modules.

---

Scope note: This review focuses on the chris host. Some items (like flake-wide inputs and nixpkgs pinning) live at the repo level but directly impact chris’s stability and maintainability.
