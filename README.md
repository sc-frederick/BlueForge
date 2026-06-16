# My OS: BlueForge

BlueForge is the desktop OS I build for myself: secure, practical, and ready for daily dev work from first boot.

It is based on `ghcr.io/ublue-os/bluefin:stable`, but tuned to my workflow: Ghostty-first terminal behavior, security tools I actually use, and runtime app management that stays simple.

## What Makes This BlueForge Different?

Compared to stock Bluefin, this is the setup my AEC team wants to live in every day.
The guiding rule: **native dnf/RPM packages wherever possible** (clean desktop
integration on bootc), Flatpak/AppImage only as a last resort.

### Added Packages (Build-time, dnf/RPM)

Baked into the image so the desktop is usable from first boot:

- **Terminal & security**: Ghostty, Helium (`helium-bin`), 1Password, Mullvad VPN.
- **Browser**: **Brave Origin** (Brave's minimal build; free on Linux) from Brave's official RPM repo.
- **Productivity & comms**: **Bitwarden** (vendor RPM), **Zoom** (vendor RPM), **Dropbox** (`nautilus-dropbox` from Dropbox's Fedora repo).
- **Office suite**: **LibreOffice** (Writer/Calc/Impress/Draw + English langpack + GNOME integration) from Fedora repos, **preconfigured to behave like MS Office** — see below.
- **Why dnf-first**: Bitwarden and the browser especially integrate far more cleanly as RPMs than as Flatpaks on a bootc system.

### Bundled GUI apps (Build-time, `/opt`)

These have no Fedora RPM/dnf repo, so the vendor's official "latest" build is baked into `/opt` with a system launcher (refreshed on image rebuild):

- **Beeper** (unified chat) — official AppImage, extracted to `/opt/beeper`.
- **Typora** (markdown editor) — official tarball in `/opt/typora`.
- **UpNote** (note-taking) — official AppImage, extracted to `/opt/upnote`.

### Added Applications (Runtime)

- **CLI tools (Homebrew)**: `bat`, `eza`, `fd`, `rg`, `gh`, `git`, `neovim`, `bun`, `pnpm`, `node`, `nvm`, `opencode`, `claude-code`, `starship`, `btop`, `tmux`.
- **JS/TS toolchain**: **bun** primary, **pnpm** fallback, **node/npm** for global CLIs. `ujust setup-js-tooling` also installs the **Vite** scaffolder and **OpenAI Codex** CLI (Codex is npm-only — Homebrew's `codex` is macOS-only).
- **GUI apps (Flatpak)**: Thunderbird, GNOME utilities, Pinta, Clapper, Flatseal, Extension Manager, Mission Center, Warehouse, Ignition, Impression, DistroShelf, Bazaar, Refine, plus GTK theme runtimes.
- **`ujust` installers for licensed/no-repo apps**:
  - `ujust install-bricscad [rpm]` — layers the account-gated **BricsCAD** RPM via `rpm-ostree`. With no argument it auto-detects the newest `BricsCAD-*.rpm` in `~/Downloads`. The RPM (~1.1GB) is licensed and stays out of the image/repo; activate with your license key on first launch.
  - `ujust install-codex` — installs the **Codex** CLI on its own.

### LibreOffice configured like MS Office

A system-wide config overlay (`custom/libreoffice/blueforge-msoffice.xcd`) sets:

- **Default save formats** to Microsoft OOXML: `.docx` / `.xlsx` / `.pptx`.
- **Tabbed "Notebookbar"** ribbon UI (closest to the MS Office ribbon) for Writer/Calc/Impress/Draw.
- **No "keep in MS format?" nag** on every save.

Users can still change any of this in *Tools > Options*. The Navigator side panel (MS Word's "navigation pane" equivalent) toggles with **F5**.

### Removed/Disabled

- **Removed**: `ptyxis` (Ghostty is preferred instead).
- **Not preinstalled**: Firefox Flatpak is intentionally not in defaults (Brave Origin is the default browser).
- **Disabled by default**: Cosign signing and SBOM attestation stay off until secrets are configured.

### Configuration Changes

- Sets Ghostty as preferred terminal via `/etc/xdg/xdg-terminals.list`.
- Enables `podman.socket` at build time.
- Copies and merges custom Brewfiles, `ujust` recipes, Flatpak preinstall manifests, and the LibreOffice config overlay into system locations.
- Uses isolated COPR installs for Ghostty and Helium to avoid repo persistence.

_Last updated: 2026-06-16_

## Build Architecture (Bluefin Pattern)

BlueForge uses a multi-stage Containerfile:

1. **`ctx` stage** assembles:
   - local `build/`
   - local `custom/`
   - `ghcr.io/projectbluefin/common` system files
   - `ghcr.io/ublue-os/brew` system files
2. **final stage** starts from `ghcr.io/ublue-os/bluefin:stable` and runs `build/10-build.sh` with `/ctx` mounted.

This keeps customization modular and reproducible while staying aligned with Universal Blue conventions.

## BlueForge Personality

If I had to describe this OS in one line: Bluefin reliability, but with my defaults already made.

- Security-first without being heavy-handed.
- Terminal-first without abandoning desktop quality-of-life.
- Runtime apps and tooling so iteration stays fast.
- Minimal surprises in day-to-day use.

## Who This Is For

- You want Bluefin stability with curated defaults.
- You prefer a terminal-first workflow but still want polished desktop UX.
- You want security tools available immediately.
- You want most tools managed at runtime instead of rebaking images constantly.

## Repo Layout

- `Containerfile` - base image, layered context, and build execution.
- `build/10-build.sh` - build-time packages (dnf/RPM + `/opt` apps) and system configuration.
- `custom/brew/*.Brewfile` - runtime CLI/dev/font package bundles.
- `custom/flatpaks/default.preinstall` - first-boot GUI app manifest.
- `custom/libreoffice/blueforge-msoffice.xcd` - system-wide LibreOffice MS-Office-like defaults.
- `custom/ujust/*.just` - user-facing app/system helpers.
- `.github/workflows/*.yml` - CI build, cleanup, Renovate, and validation workflows.

## Customizing

Where to make changes:

- **Build-time system changes** (dnf/RPM packages, `/opt` apps, system config): edit `build/10-build.sh`.
- **Runtime CLI tools**: edit `custom/brew/default.Brewfile` and related Brewfiles.
- **Runtime GUI apps**: edit `custom/flatpaks/default.preinstall`.
- **User shortcuts**: edit `custom/ujust/custom-apps.just` and `custom/ujust/custom-system.just`.

## Local Build and Test

```bash
just build
just build-qcow2
just run-vm-qcow2
```

Optional ISO flow:

```bash
just build-iso
just run-vm-iso
```

## Deploy

```bash
sudo bootc switch ghcr.io/sc-frederick/blueforge:stable
sudo systemctl reboot
```

## Optional: Enable Signing (Production)

Signing is intentionally disabled by default so first builds work immediately.

When ready:

1. Generate keys with `cosign generate-key-pair`.
2. Add private key contents to GitHub Actions secret `SIGNING_SECRET`.
3. Commit your real `cosign.pub`.
4. Uncomment signing steps in `.github/workflows/build.yml`.
5. (Optional) Uncomment SBOM generation + attestation steps.

Never commit `cosign.key`.

## Useful Commands After First Boot

Install runtime packages:

```bash
ujust install-default-apps
ujust install-dev-tools
ujust install-fonts
ujust install-all-brew
```

Set up the JS/TS toolchain (bun + pnpm + Vite + Codex) and AEC apps:

```bash
ujust setup-js-tooling                 # bun, pnpm, node, Vite scaffolder, Codex CLI
ujust install-codex                    # Codex CLI only
ujust install-bricscad                 # licensed; auto-detects RPM in ~/Downloads
```

Extra helpers:

```bash
ujust install-jetbrains-toolbox
ujust configure-dev-groups
ujust clean-containers
ujust update-and-reboot
```

## Validation and CI

PRs run validations for:

- Shell scripts (`shellcheck`)
- Brewfile syntax
- Flatpak IDs
- Justfile syntax
- Renovate config

Main branch builds and publishes the `stable` image tags.

## Learn More

- Universal Blue: <https://universal-blue.org/>
- Bluefin: <https://projectbluefin.io>
- bootc: <https://containers.github.io/bootc/>
- Flatpak app IDs: <https://flathub.org/>
