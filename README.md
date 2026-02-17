# My OS: BlueForge

BlueForge is the desktop OS I build for myself: secure, practical, and ready for daily dev work from first boot.

It is based on `ghcr.io/ublue-os/bluefin:stable`, but tuned to my workflow: Ghostty-first terminal behavior, security tools I actually use, and runtime app management that stays simple.

## What Makes This BlueForge Different?

Compared to stock Bluefin, this is the setup I want to live in every day.

### Added Packages (Build-time)

- **System packages**: Ghostty, Helium (`helium-bin`), 1Password, Mullvad VPN.
- **Why these are baked in**: login/network security are non-negotiable, and the terminal should feel right immediately.

### Added Applications (Runtime)

- **CLI tools (Homebrew)**: `bat`, `eza`, `fd`, `rg`, `gh`, `git`, `neovim`, `bun`, `nvm`, `opencode`, `claude-code`, `starship`, `htop`, `tmux`.
- **GUI apps (Flatpak)**: Thunderbird, GNOME utilities, Flatseal, Mission Center, Warehouse, Ignition, Impression, DistroShelf, Bazaar, Refine, plus GTK theme runtimes.
- **Why most apps stay runtime-managed**: faster iteration and easier updates without rebuilding the base image.

### Removed/Disabled

- **Removed**: `ptyxis` (Ghostty is preferred instead).
- **Not preinstalled**: Firefox Flatpak is intentionally not in defaults.
- **Disabled by default**: Cosign signing and SBOM attestation stay off until secrets are configured.

### Configuration Changes

- Sets Ghostty as preferred terminal via `/etc/xdg/xdg-terminals.list`.
- Enables `podman.socket` at build time.
- Copies and merges custom Brewfiles, `ujust` recipes, and Flatpak preinstall manifests into system locations.
- Uses isolated COPR installs for Ghostty and Helium to avoid repo persistence.

_Last updated: 2026-02-16_

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
- `build/10-build.sh` - build-time packages and system configuration.
- `custom/brew/*.Brewfile` - runtime CLI/dev/font package bundles.
- `custom/flatpaks/default.preinstall` - first-boot GUI app manifest.
- `custom/ujust/*.just` - user-facing app/system helpers.
- `.github/workflows/*.yml` - CI build, cleanup, Renovate, and validation workflows.

## Quick Start

### 1) Use this template

Create a new GitHub repo from this template.

### 2) Rename identity everywhere

Set your OS/repo name consistently in:

1. `Containerfile` (`# Name: your-name`)
2. `Justfile` (`export image_name := env("IMAGE_NAME", "your-name")`)
3. `README.md` title
4. `artifacthub-repo.yml` (`repositoryID: your-name`)
5. `custom/ujust/README.md` (`localhost/your-name:stable` examples)
6. `.github/workflows/clean.yml` package reference

### 3) Enable Actions permissions

In GitHub repo settings:

- Enable Actions.
- Set workflow permissions to **Read and write**.
- Enable permission for Actions to create/approve PRs.

### 4) Customize your image

- **Build-time system changes**: edit `build/10-build.sh`.
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
sudo bootc switch ghcr.io/<your-user>/<your-repo>:stable
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
