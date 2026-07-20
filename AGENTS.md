# Agent Instructions for BlueForge

BlueForge is a thin, developer-focused downstream image built from
`ghcr.io/ublue-os/bluefin:stable`. Preserve Bluefin's atomic bootc architecture
and the host-first `~/Work` development model.

## External references

Use the authenticated GitHub API/MCP tools when inspecting external GitHub
repositories. Do not use `curl`, `wget`, or unauthenticated raw GitHub URLs for
repository research.

Primary upstream references:

- `ublue-os/bluefin`
- `projectbluefin/common`
- `ublue-os/brew`
- `bootc-dev/bootc`

Confirm current Bluefin conventions before introducing a downstream replacement
for functionality already supplied by the base image.

## Architecture

```text
Bluefin stable image
└── BlueForge system layer
    ├── build/10-build.sh          RPMs and system integration
    ├── custom/brew/preinstall.d  automatic user toolchain
    ├── custom/brew/*.Brewfile    optional user bundles
    ├── custom/npm                npm-only user tools
    ├── custom/flatpaks           post-install GUI apps
    ├── custom/distrobox          optional shared environments
    └── custom/ujust              user-facing orchestration
```

The Containerfile must not copy a second version of Bluefin common resources
over the selected Bluefin base. BlueForge-owned inputs are mounted at `/ctx` and
applied by `build/10-build.sh`.

## Package placement

### Image packages

Use `build/10-build.sh` for packages with system integration: services, udev
rules, drivers, firmware, D-Bus services, PAM, desktop integration, or files
that must exist before login.

- Use `dnf5` exclusively, always with `-y`.
- Install Fedora packages before COPR packages.
- Use `copr_install_isolated` for COPRs.
- Remove third-party repository files after installation.
- Never use `rpm-ostree install`.

### Automatic user tools

Put universal user tools in
`custom/brew/preinstall.d/blueforge.Brewfile`. Bluefin's supported
`brew-preinstall.service` owns reconciliation after first login and image
updates.

- Homebrew 6 third-party taps require `trusted: true`.
- Do not duplicate packages already supplied by the image or Bluefin's own
  managed Brewfiles.
- Keep hardware-specific and project-specific packages out of this set.

### Optional and project tools

Optional host tools go in another Brewfile and receive a corresponding `ujust`
recipe. Project runtimes belong in lockfiles, `mise.toml`, `uv`, or a
repository-local devcontainer. Shared mutable SDKs may use Distrobox.

Never run `dnf5` or `rpm-ostree` from a `ujust` recipe.

## Development model

- Repositories live directly under `~/Work`.
- Codex, Claude Code, OpenCode, Cursor, and T3 Code remain host/user tools.
- Devcontainers are opt-in for dependency conflicts, multi-service stacks,
  legacy SDKs, or CI parity.
- Firmware builds may run in a container while serial access, udev rules,
  flashing, and debugging remain on the host.
- Projects should expose stable `just setup`, `just dev`, `just test`, and
  `just build` commands where practical.

Update `docs/development-workflow.md` or `docs/firmware-development.md` when
changing this model.

## Repository map

- `Containerfile` — base image and bootc build layer.
- `build/10-build.sh` — all active image mutations.
- `custom/brew/` — managed and optional Brewfiles.
- `custom/scripts/` — user setup helpers installed under `/usr/libexec`.
- `custom/systemd/` — user units and presets.
- `custom/ujust/` — runtime commands.
- `custom/flatpaks/` — Flatpak preinstall INI files.
- `custom/distrobox/` — optional assemble manifests.
- `docs/` — user-facing architecture and workflows.
- `iso/` — local installer image configuration.
- `.github/workflows/` — build, update, and validation automation.

## Required validation

Run checks relevant to every changed file before requesting a commit:

```bash
shellcheck -x build/*.sh custom/scripts/*.sh
bash -n build/*.sh custom/scripts/*.sh
just --list
just --unstable --fmt --check -f Justfile
just --unstable --fmt --check -f custom/ujust/custom-apps.just
just --unstable --fmt --check -f custom/ujust/custom-system.just
python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/build.yml"))'
python3 -c 'import tomllib; tomllib.load(open("iso/iso.toml", "rb"))'
```

Also validate every modified YAML file and inspect Brewfile/Flatpak CI behavior.
A full image build is appropriate after system package or build-script changes
when local resources permit it.

## Documentation contract

Whenever packages or configuration change, update the README section “What
Makes This BlueForge Different?” and its `Last updated` date. Explain why a
change helps a user, not merely which package was added.

Keep `.github/copilot-instructions.md` pointing to this file.

## Git policy

- Do development on a branch; never push directly to `main`.
- Do not commit or push without explicit user confirmation.
- Use Conventional Commits: `<type>[optional scope]: <description>`.
- Preserve unrelated user changes in a dirty worktree.
- Never commit `cosign.key`.
- Let pull-request validation finish before merging.

Before every commit, run the required validation and review the complete diff.
