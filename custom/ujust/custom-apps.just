# vim: set ft=make :
####################
### custom-apps.just
####################
## Runtime app installers: Homebrew bundles, dev toolchains, and licensed/no-repo apps.

# Install default applications via Homebrew
[group('Apps')]
install-default-apps:
    #!/usr/bin/env bash
    echo "Installing default applications via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile

# Install development tools via Homebrew
[group('Apps')]
install-dev-tools:
    #!/usr/bin/env bash
    echo "Installing development tools via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile

# Install fonts via Homebrew
[group('Apps')]
install-fonts:
    #!/usr/bin/env bash
    echo "Installing fonts via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile

# Install all Brewfiles at once
[group('Apps')]
install-all-brew:
    #!/usr/bin/env bash
    echo "Installing all applications from Brewfiles..."
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile

# Install JetBrains Toolbox for managing JetBrains IDEs
[group('Apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    echo "Installing JetBrains Toolbox..."
    pushd "$(mktemp -d)"
    echo "Fetching latest version..."
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    mkdir -p $HOME/.local/share/JetBrains/ToolboxApp/
    mv jetbrains-toolbox-"${BUILD_VERSION}"/* $HOME/.local/share/JetBrains/ToolboxApp/
    popd
    echo "Launching JetBrains Toolbox..."
    $HOME/.local/share/JetBrains/ToolboxApp/bin/jetbrains-toolbox

# Shortcut for install-jetbrains-toolbox
[group('Apps')]
jetbrains-toolbox:
    @ujust install-jetbrains-toolbox

# Install Vite+ (vp): unified JS/TS toolchain — runtime, package manager, and tools
[group('Apps')]
install-vite-plus:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing Vite+ (vp) — unified JS/TS toolchain..."
    # VP_NODE_MANAGER=yes lets Vite+ manage Node non-interactively, so vp provides
    # node/npm itself (no separate Homebrew Node needed). The installer adds
    # 'source ~/.vite-plus/env' to your shell rc files.
    curl -fsSL https://vite.plus | VP_NODE_MANAGER=yes bash
    echo ""
    echo "Done. Open a new terminal (or 'source ~/.vite-plus/env'), then 'vp help'."
    echo "Vite+ manages your Node version, package manager, dev server, tests,"
    echo "lint/format, and production builds — all from the 'vp' command."

# Full JS/TS dev setup: the Vite+ toolchain plus the OpenAI Codex CLI
[group('Apps')]
setup-js-tooling:
    #!/usr/bin/env bash
    set -euo pipefail
    ujust install-vite-plus
    ujust install-codex
    echo ""
    echo "Done. 'vp' is your toolchain entry point; 'codex' is the OpenAI CLI."

# Install the OpenAI Codex CLI (npm global, via the Vite+-managed Node)
[group('Apps')]
install-codex:
    #!/usr/bin/env bash
    set -euo pipefail
    # Prefer the Vite+-managed Node/npm; fall back to any npm already on PATH.
    VP_ENV="${VP_HOME:-${HOME}/.vite-plus}/env"
    # shellcheck source=/dev/null
    [ -f "${VP_ENV}" ] && source "${VP_ENV}"
    if ! command -v npm &>/dev/null; then
        echo "npm not found. Install the Vite+ toolchain first:"
        echo "    ujust install-vite-plus"
        exit 1
    fi
    echo "Installing OpenAI Codex CLI..."
    npm install -g @openai/codex
    echo "Done. Run 'codex' and sign in with your ChatGPT account or OPENAI_API_KEY."

# Install BricsCAD from a vendor RPM (account-gated download; license required)
[group('Apps')]
install-bricscad RPM_PATH="":
    #!/usr/bin/env bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh 2>/dev/null || true
    RPM="{{ RPM_PATH }}"
    # No path given: try to auto-locate the newest BricsCAD RPM in ~/Downloads.
    if [ -z "${RPM}" ]; then
        shopt -s nullglob
        CANDIDATES=("${HOME}"/Downloads/BricsCAD-*.rpm "${HOME}"/Downloads/bricscad*.rpm)
        shopt -u nullglob
        if [ "${#CANDIDATES[@]}" -gt 0 ]; then
            # Pick the most recently modified match.
            RPM="$(ls -t "${CANDIDATES[@]}" | head -n1)"
            echo "Found BricsCAD RPM: ${RPM}"
        fi
    fi
    if [ -z "${RPM}" ]; then
        echo "BricsCAD is a licensed product and its RPM is behind a Bricsys login."
        echo ""
        echo "  1. Download the Linux RPM (Fedora/openSUSE) from:"
        echo "       https://www.bricsys.com/download"
        echo "  2. Drop it in ~/Downloads and just run 'ujust install-bricscad',"
        echo "     or pass the path explicitly, e.g.:"
        echo "       ujust install-bricscad ~/Downloads/BricsCAD-*.rpm"
        echo ""
        echo "It will be layered with 'rpm-ostree install' (a reboot applies it)."
        echo "After install, launch BricsCAD and enter your license key to activate."
        exit 0
    fi
    if [ ! -f "${RPM}" ]; then
        echo "File not found: ${RPM}"
        exit 1
    fi
    echo "Layering BricsCAD (${RPM}) — this modifies the base image and needs a reboot..."
    sudo rpm-ostree install "${RPM}"
    echo "Done. Reboot to finish: 'systemctl reboot'."
    echo "After reboot, launch BricsCAD and enter your license key to activate."
    echo "Note: BricsCAD may need legacy libs (e.g. gtk2). If it fails to launch,"
    echo "      run 'rpm-ostree install gtk2' and reboot."

# Install a Flatpak application from Flathub
[group('Apps')]
install-flatpak APP_ID:
    #!/usr/bin/bash
    echo "Installing {{ APP_ID }} from Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub {{ APP_ID }}
