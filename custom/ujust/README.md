# BlueForge `ujust` Commands

The build concatenates these recipes into Bluefin's
`/usr/share/ublue-os/just/60-custom.just`. They are user-facing orchestration;
they must not mutate the bootc image with `dnf5` or `rpm-ostree`.

## Development

```bash
ujust setup-workspace          # Ensure ~/Work exists
ujust blueforge-dev-status     # Check development and container tools
ujust install-blueforge-tools  # Reconcile the automatic toolchain now
ujust install-ai-tools         # Refresh OpenCode and T3 Code
ujust install-dev-tools        # Optional host-native build tools
ujust install-fonts            # Optional Nerd Fonts
```

## Firmware

```bash
ujust configure-firmware-access
ujust create-firmware-box
ujust firmware-shell
```

The shared Distrobox is a convenience environment, not a requirement. A project
that needs a pinned SDK or CI parity should carry its own devcontainer and expose
stable commands such as `just build`, `just test`, and `just flash`.

## Maintenance

```bash
ujust clean-containers
ujust update-and-reboot
```

Container cleanup asks before removing unused rootless Podman data.

## Authoring rules

- Use a verb-oriented kebab-case recipe name.
- Add a `[group('...')]` attribute.
- Use `#!/usr/bin/env bash` and `set -euo pipefail` for multi-line recipes.
- Quote shell variables and avoid implicit destructive behavior.
- Install user applications with Homebrew or Flatpak.
- Put system dependencies in `build/10-build.sh`, not in a `ujust` recipe.

Validate with:

```bash
just --unstable --fmt --check -f custom/ujust/custom-apps.just
just --unstable --fmt --check -f custom/ujust/custom-system.just
```
