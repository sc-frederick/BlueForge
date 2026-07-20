# BlueForge

BlueForge is a developer-focused, customized Bluefin workstation. It keeps the
atomic, image-based Bluefin system intact while making a normal `~/Work`
workflow productive from the first login.

The default is deliberately host-first: clone a repository, open it with Cursor
or T3 Code, and run Codex, Claude Code, or OpenCode from the repository root.
Devcontainers and Distrobox are available when a project benefits from them;
they are not a requirement for every project.

## What Makes This BlueForge Different?

BlueForge is based on `ghcr.io/ublue-os/bluefin:stable` and adds the following
opinionated defaults.

### Added Packages (Build-time)

- **Desktop and security**: Ghostty, 1Password, Mullvad VPN, Brave Origin,
  Bitwarden, Zoom, and Dropbox integration.
- **Productivity**: LibreOffice with OOXML defaults and a tabbed interface.
- **Bundled applications**: Beeper, Typora, and UpNote under immutable `/opt`.
- **System integration only**: build-time RPMs are reserved for applications,
  services, and configuration that genuinely belong to the host image.

### Added Applications (User runtime)

Bluefin's supported `brew-preinstall.service` installs and reconciles the
OS-managed toolchain for every user:

- **Coding agents**: Claude Code and OpenCode through Homebrew; Codex through
  its official npm package.
- **Developer interfaces**: Cursor and the T3 Code CLI.
- **Project tools**: `devcontainer`, `mise`, `direnv`, `uv`, Node, Vite+,
  GitHub CLI, Neovim, LazyGit, and modern shell utilities.
- **Optional host build bundle**: CMake, Ninja, ccache, ShellCheck, shfmt,
  Hyperfine, and Watchexec through `ujust install-dev-tools`.
- **GUI applications**: the curated Flatpak set in
  `custom/flatpaks/default.preinstall` is downloaded after installation.

User-owned packages are not baked into the bootc filesystem. They are installed
automatically after first login, remain writable, and follow Bluefin's normal
Homebrew lifecycle. Authentication for AI tools remains per-user.

### Removed/Disabled

- **Removed**: BricsCAD and the unsupported `rpm-ostree` layering workflow.
- **Removed**: the custom Homebrew login service; BlueForge now uses Bluefin's
  content-addressed `brew-preinstall.service`.
- **Removed**: Ptyxis, because Ghostty is the preferred terminal.
- **Not required**: devcontainers are opt-in rather than the default place for
  source code.
- **Disabled by default**: image signing and SBOM attestation until their
  production configuration is enabled.

### Configuration Changes

- Creates `~/Work` for every user without changing existing repositories.
- Makes Codex, Claude Code, OpenCode, Cursor, and T3 Code available globally.
- Provides an optional shared `blueforge-firmware` Distrobox and host serial
  permission helper.
- Sets Ghostty as the preferred terminal.
- Enables the Podman socket for rootless container workflows.
- Keeps third-party repositories temporary during image builds.

_Last updated: 2026-07-20_

## Development Model

The normal workflow remains ordinary Linux development:

```bash
cd ~/Work
git clone git@github.com:OWNER/PROJECT.git
cd PROJECT
codex        # or claude, opencode, cursor, or t3
```

Projects should provide lockfiles, a small `just` command interface, and an
`AGENTS.md` when agent-specific guidance is useful. Add a devcontainer only for
conflicting dependencies, multi-service applications, legacy SDKs, or strict CI
parity.

The complete policy is in [Development Workflow](docs/development-workflow.md).
Firmware and hardware boundaries are covered in
[Firmware Development](docs/firmware-development.md).

## Application Architecture

BlueForge follows this placement rule:

| Need | Location | Lifecycle |
| --- | --- | --- |
| Driver, daemon, udev rule, desktop integration | `build/10-build.sh` | Image update |
| Universal user CLI/IDE | `custom/brew/preinstall.d/` | Automatic first-login reconciliation |
| Optional host build tool | `custom/brew/*.Brewfile` | Explicit `ujust` command |
| GUI app from Flathub | `custom/flatpaks/` | Flatpak preinstall |
| Project runtime or SDK | Repository / devcontainer | Project-defined |
| Shared mutable SDK | Distrobox | User-managed |

Do not use `rpm-ostree install`. A system dependency should be baked into the
image; a user tool should use Homebrew/Flatpak; a project dependency should be
declared by the project or placed in a container.

## First Login

Bluefin installs Homebrew, then applies
`/usr/share/ublue-os/homebrew/preinstall.d/blueforge.Brewfile`. BlueForge's user
setup creates `~/Work` and installs the official Codex and T3 Code npm packages.
The npm packages are refreshed at most weekly while ordinary logins take a
local fast path.

Check or repair provisioning with:

```bash
ujust blueforge-dev-status
ujust install-blueforge-tools
ujust install-ai-tools
```

Each agent still requires its own login:

```bash
codex login
claude auth login
opencode auth login
```

## Firmware Workflow

For a convenient shared build environment:

```bash
ujust configure-firmware-access
ujust create-firmware-box
ujust firmware-shell
```

The box sees the same `~/Work` directory. Prefer containerized builds and
host-side flashing/debugging. Repositories that need an exact SDK should carry a
devcontainer and expose stable `just build`, `just test`, and `just flash`
commands.

## Build Architecture

BlueForge is intentionally a thin downstream layer:

1. `Containerfile` starts from the stable Bluefin image selected by
   `BASE_IMAGE`.
2. A scratch context contains only BlueForge's `build/`, `custom/`, and `docs/`.
3. `build/10-build.sh` installs system applications and copies declarative user
   configuration into the final image.
4. `bootc container lint` validates the result.

Bluefin's common desktop and Homebrew resources are inherited from the base;
BlueForge does not copy a second, potentially mismatched version over them.

## Repository Layout

- `Containerfile` — Bluefin base selection and bootc build.
- `build/10-build.sh` — build-time packages and system integration.
- `custom/brew/` — automatic and optional Homebrew bundles.
- `custom/npm/` — npm tools that lack a supported Linux Homebrew cask.
- `custom/distrobox/` — optional shared development environments.
- `custom/flatpaks/` — post-install GUI applications.
- `custom/ujust/` — user-facing setup and maintenance commands.
- `docs/` — development and firmware operating model.
- `.github/workflows/` — validation and image publishing.

## Local Build and Test

```bash
just build
just build-qcow2
just run-vm-qcow2
```

Optional installer ISO:

```bash
just build-iso
just run-vm-iso
```

Run the fast validations before attempting a full image build:

```bash
just --list
shellcheck build/*.sh custom/scripts/*.sh
python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/build.yml"))'
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

Installer configuration already points to these images in `iso/iso.toml` and
`iso/iso-nvidia.toml`.

## Updates

- The workflow rebuilds weekly and whenever `main` changes, so the moving
  Bluefin `stable` base is regularly consumed.
- Renovate maintains actions and container references through pull requests.
- Users apply a published image with `ujust update-and-reboot` or Bluefin's
  normal update UI.
- Homebrew packages follow Bluefin's managed upgrade lifecycle.

## Optional Production Signing

Signing is disabled so initial builds work without secrets. To enable it:

1. Generate a key pair with `cosign generate-key-pair`.
2. Store the private key as the GitHub Actions secret `SIGNING_SECRET`.
3. Keep only `cosign.pub` in the repository.
4. Enable the signing and optional SBOM sections in
   `.github/workflows/build.yml`.

Never commit `cosign.key`.
