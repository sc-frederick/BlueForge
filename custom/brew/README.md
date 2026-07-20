# BlueForge Homebrew Bundles

BlueForge uses Bluefin's supported Homebrew lifecycle. Homebrew itself and all
packages remain user-owned; the bootc image only ships declarative Brewfiles.

## Automatic packages

Files under `preinstall.d/` are copied to
`/usr/share/ublue-os/homebrew/preinstall.d/`. Bluefin's
`brew-preinstall.service` hashes all managed Brewfiles and:

- installs additions after first login or an image update;
- removes packages that disappeared from the OS-managed set;
- leaves independently installed user packages alone;
- exits quickly when nothing changed.

`preinstall.d/blueforge.Brewfile` is the default developer workstation. It
contains universal CLI tools, Claude Code, OpenCode, Cursor, Node, and the
devcontainer tooling. Codex and T3 Code are provisioned from their official npm
packages by `blueforge-user-setup.service`.

Third-party taps must use Homebrew 6 trust syntax:

```ruby
tap "example/tap", trusted: true
```

## Optional bundles

- `development.Brewfile` contains host-native build tools for repositories that
  intentionally do not use a container.
- `fonts.Brewfile` contains additional Nerd Fonts.

Install them with:

```bash
ujust install-dev-tools
ujust install-fonts
```

Language runtimes should normally be pinned by a repository with `mise`, `uv`,
or the language's standard toolchain file instead of being added globally.

## Placement rules

Homebrew is for self-contained user tools. Packages that need systemd services,
udev rules, kernel modules, D-Bus system services, firmware, PAM, or filesystem
drivers belong in `build/10-build.sh` as RPMs. Project SDKs belong in the
project or an optional container.

Validate a changed bundle with:

```bash
brew bundle check --file custom/brew/preinstall.d/blueforge.Brewfile
```
