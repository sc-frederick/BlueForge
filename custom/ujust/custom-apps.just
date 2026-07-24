# vim: set ft=make :
####################
### custom-apps.just
####################
## User-owned applications and developer toolchains.

# Reconcile the complete OS-managed BlueForge toolchain now.
[group('Development')]
install-blueforge-tools:
    #!/usr/bin/env bash
    set -euo pipefail
    brew bundle --file /usr/share/ublue-os/homebrew/preinstall.d/blueforge.Brewfile
    /usr/libexec/blueforge-user-setup

# Backward-compatible name for the managed BlueForge toolchain.
[group('Development')]
install-default-apps:
    @ujust install-blueforge-tools

# Reinstall or update OpenCode and T3 Code.
[group('Development')]
install-ai-tools:
    #!/usr/bin/env bash
    set -euo pipefail
    brew bundle --file /usr/share/ublue-os/homebrew/preinstall.d/blueforge.Brewfile
    /usr/libexec/blueforge-user-setup
    npm install --global t3@latest
    echo "AI tools are installed. Authenticate with OpenCode as needed."

# Install the optional host-native build tool bundle.
[group('Development')]
install-dev-tools:
    #!/usr/bin/env bash
    set -euo pipefail
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile

# Install the optional programming font bundle.
[group('Apps')]
install-fonts:
    #!/usr/bin/env bash
    set -euo pipefail
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile

# Install the managed toolchain plus all optional Brewfiles.
[group('Development')]
install-all-brew:
    #!/usr/bin/env bash
    set -euo pipefail
    brew bundle --file /usr/share/ublue-os/homebrew/preinstall.d/blueforge.Brewfile
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile
    /usr/libexec/blueforge-user-setup

# Install JetBrains Toolbox using Bluefin's maintained Linux cask.
[group('Apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    set -euo pipefail
    brew tap --trust ublue-os/tap
    brew install --cask ublue-os/tap/jetbrains-toolbox-linux

# Install a Flatpak application from Flathub.
[group('Apps')]
install-flatpak APP_ID:
    #!/usr/bin/env bash
    set -euo pipefail
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub "{{ APP_ID }}"
