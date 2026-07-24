# BlueForge

BlueForge is a thin, developer-focused downstream of
[`ghcr.io/ublue-os/bluefin:stable`](https://projectbluefin.io). It keeps Bluefin's
atomic bootc system intact while making a normal `~/Work` workflow productive
from the first login.

The default is host-first: clone a repository under `~/Work`, then run OpenCode
or T3 Code from the repository root.
Devcontainers and Distrobox are available when a project benefits from them;
they are not required for every repository.

Two published images are built every week and on every `main` change:

| Image | Base | Use when |
| --- | --- | --- |
| `ghcr.io/sc-frederick/blueforge:stable` | `bluefin:stable` | Default workstation |
| `ghcr.io/sc-frederick/blueforge-nvidia:stable` | `bluefin-nvidia:stable` | Closed Nvidia driver |

## What Makes This BlueForge Different?

BlueForge layers opinionated defaults on Bluefin without replacing Bluefin's
desktop, Homebrew, or update stack.

### Image packages (`build/10-build.sh`)

System packages that need desktop integration, services, or files before login:

- **Terminal**: Ghostty (Ptyxis removed); preferred via
  `/etc/xdg/xdg-terminals.list`.
- **Desktop and security**: Bitwarden, Mullvad VPN, Brave Origin, Zoom, and
  Dropbox Nautilus integration.
- **Productivity**: LibreOffice Writer/Calc/Impress/Draw with English langpack,
  GTK4 integration, OOXML save defaults, and a tabbed Notebookbar UI.
- **Bundled under `/opt`**: Beeper, Typora, and UpNote (vendor builds with
  system launchers; refreshed on image rebuild).
- **Host services**: rootless Podman socket enabled at build time.

Third-party RPM repositories are added only for the install transaction and
removed afterward. Prefer `dnf5` RPMs for host integration; never
`rpm-ostree install`.

### Automatic user toolchain

Bluefin's `brew-preinstall.service` installs and reconciles
`custom/brew/preinstall.d/blueforge.Brewfile` after first login and image
updates. BlueForge's `blueforge-user-setup.service` then creates `~/Work` and
installs npm-only tools.

**Homebrew (automatic):**

- Coding agent: OpenCode
- Project tools: `devcontainer`, `mise`, `direnv`, `uv`, Node, Vite+, GitHub CLI,
  Neovim, LazyGit
- Shell utilities: `bat`, `eza`, `fd`, `ripgrep`

**npm (automatic, weekly refresh):**

- T3 Code (`t3`)

User-owned packages stay writable and follow Bluefin's Homebrew lifecycle.
Authentication for AI tools remains per-user.
Cursor, Codex, and Claude Code are not provisioned by default.

### Optional user bundles

| Command | Bundle |
| --- | --- |
| `ujust install-dev-tools` | CMake, Ninja, ccache, ShellCheck, shfmt, Hyperfine, Watchexec |
| `ujust install-fonts` | Common Nerd Fonts |
| `ujust install-jetbrains-toolbox` | JetBrains Toolbox (ublue Linux cask) |
| `ujust install-all-brew` | Managed toolchain plus optional Brewfiles |

### Flatpaks

`custom/flatpaks/default.preinstall` preinstalls Aerion (email), core GNOME apps,
and utilities such as Flatseal, Extension Manager, Mission Center, Warehouse,
DistroShelf, and Bazaar after installation.

### Configuration and workflow defaults

- Creates `~/Work` for every user without touching existing repositories.
- Ships offline copies of the development docs under `/usr/share/doc/blueforge`.
- Provides an optional shared `blueforge-firmware` Distrobox and a host serial
  permission helper (`ujust configure-firmware-access`).
- Image signing and SBOM attestation stay disabled until production secrets are
  configured.

_Last updated: 2026-07-23_

## Development Model

```bash
cd ~/Work
git clone git@github.com:OWNER/PROJECT.git
cd PROJECT
opencode     # or t3
```

Projects should provide lockfiles, a small `just` interface (`setup`, `dev`,
`test`, `build`), and an `AGENTS.md` when agent-specific guidance helps. Add a
devcontainer only for conflicting dependencies, multi-service stacks, legacy
SDKs, or strict CI parity.

Full policy: [Development Workflow](docs/development-workflow.md).  
Firmware boundaries: [Firmware Development](docs/firmware-development.md).

## Application Architecture

| Need | Location | Lifecycle |
| --- | --- | --- |
| Driver, daemon, udev rule, desktop integration | `build/10-build.sh` | Image update |
| Universal user CLI/IDE | `custom/brew/preinstall.d/` | Automatic first-login reconciliation |
| npm-only user tools | `custom/npm/` | `blueforge-user-setup.service` |
| Optional host tools | `custom/brew/*.Brewfile` | Explicit `ujust` command |
| GUI app from Flathub | `custom/flatpaks/` | Flatpak preinstall |
| Project runtime or SDK | Repository / devcontainer | Project-defined |
| Shared mutable SDK | Distrobox | User-managed |

A system dependency belongs in the image. A user tool uses Homebrew, npm, or
Flatpak. A project dependency is declared by the project or placed in a
container.

## First Login

1. Bluefin installs Homebrew and applies
   `/usr/share/ublue-os/homebrew/preinstall.d/blueforge.Brewfile`.
2. `blueforge-user-setup` creates `~/Work` and installs T3 Code.
3. Moving npm packages refresh at most weekly; ordinary logins take a local fast
   path.

Check or repair provisioning:

```bash
ujust blueforge-dev-status
ujust install-blueforge-tools
ujust install-ai-tools
```

Authenticate OpenCode separately:

```bash
opencode auth login
```

## Firmware Workflow

```bash
ujust configure-firmware-access
ujust create-firmware-box
ujust firmware-shell
```

The box shares `~/Work`. Prefer containerized builds and host-side
flashing/debugging. Repositories that need an exact SDK should carry a
devcontainer and expose stable `just build`, `just test`, and `just flash`
commands.

## Build Architecture

1. `Containerfile` starts from the Bluefin image selected by `BASE_IMAGE`.
2. A scratch context contains only BlueForge's `build/`, `custom/`, and `docs/`.
3. `build/10-build.sh` installs system packages and copies declarative user
   configuration into the image.
4. `bootc container lint` validates the result.

Bluefin's common desktop and Homebrew resources are inherited from the base.
BlueForge does not copy a second, potentially mismatched copy over them.

## Repository Layout

- `Containerfile` — Bluefin base selection and bootc build.
- `build/10-build.sh` — build-time packages and system integration.
- `custom/brew/` — automatic (`preinstall.d/`) and optional Homebrew bundles.
- `custom/npm/` — npm tools without a supported Linux Homebrew cask.
- `custom/scripts/` — user setup helpers installed under `/usr/libexec`.
- `custom/systemd/` — user units and presets for first-login setup.
- `custom/distrobox/` — optional shared development environments.
- `custom/flatpaks/` — post-install GUI applications.
- `custom/libreoffice/` — system-wide OOXML / Notebookbar defaults.
- `custom/ujust/` — user-facing setup and maintenance commands.
- `docs/` — development and firmware operating model.
- `iso/` — local installer image configuration.
- `.github/workflows/` — validation and image publishing.

## Local Build and Test

```bash
just build
just build-qcow2
just run-vm-qcow2
```

Nvidia variant:

```bash
BASE_IMAGE=ghcr.io/ublue-os/bluefin-nvidia:stable just build blueforge-nvidia stable
```

Optional installer ISO:

```bash
just build-iso
just build-iso-nvidia
just run-vm-iso
```

Fast validation before a full image build (see `AGENTS.md` for the full set):

```bash
just --list
shellcheck -x build/*.sh custom/scripts/*.sh
just --unstable --fmt --check -f Justfile
python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/build.yml"))'
python3 -c 'import tomllib; tomllib.load(open("iso/iso.toml", "rb"))'
```

## Deploy

Standard image:

```bash
sudo bootc switch ghcr.io/sc-frederick/blueforge:stable
sudo systemctl reboot
```

Nvidia image:

```bash
sudo bootc switch ghcr.io/sc-frederick/blueforge-nvidia:stable
sudo systemctl reboot
```

Installer configuration already points at these images in `iso/iso.toml` and
`iso/iso-nvidia.toml`. After deploy, apply later updates with
`ujust update-and-reboot` or Bluefin's normal update UI.

## Updates

- CI rebuilds weekly (Monday) and whenever `main` changes, so the moving Bluefin
  `stable` base is regularly consumed.
- Renovate maintains actions and container references through pull requests.
- Homebrew packages follow Bluefin's managed upgrade lifecycle.
- npm tools (`t3`) refresh at most weekly via user setup.

## Optional Production Signing

Signing is disabled so initial builds work without secrets. To enable it:

1. Generate a key pair with `cosign generate-key-pair`.
2. Store the private key as the GitHub Actions secret `SIGNING_SECRET`.
3. Keep only `cosign.pub` in the repository.
4. Enable the signing and optional SBOM sections in
   `.github/workflows/build.yml`.

Never commit `cosign.key`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md). Work on a
branch, keep packages in the correct layer, update this README's “What Makes
This BlueForge Different?” section when defaults change, and run the validation
commands before opening a pull request.
