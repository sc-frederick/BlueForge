#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::group:: Copy Bluefin Config from Common"

# Copy just files from @projectbluefin/common (includes 00-entry.just which imports 60-custom.just)
mkdir -p /usr/share/ublue-os/just/
shopt -s nullglob
cp -r /ctx/oci/common/bluefin/usr/share/ublue-os/just/* /usr/share/ublue-os/just/
shopt -u nullglob

echo "::endgroup::"

echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/

# Consolidate Just Files
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just

# Copy Flatpak preinstall files
mkdir -p /etc/flatpak/preinstall.d/
cp /ctx/custom/flatpaks/*.preinstall /etc/flatpak/preinstall.d/

echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
copr_install_isolated "scottames/ghostty" ghostty

# Install 1Password from official repository
rpm --import https://downloads.1password.com/linux/keys/1password.asc
cat > /etc/yum.repos.d/1password.repo << 'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
dnf5 install -y 1password
rm -f /etc/yum.repos.d/1password.repo

# Install Mullvad VPN from official repository
dnf5 config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
dnf5 install -y mullvad-vpn
rm -f /etc/yum.repos.d/mullvad.repo

# Install Brave Origin browser from Brave's official repository.
# "Brave Origin" is the de-Googled/minimal Brave build (free on Linux). The repo
# file ships both `brave-browser` and `brave-origin`; we install Origin per the
# AEC team's preference. Swap the package name below for `brave-browser` to get
# the standard build instead.
dnf5 config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 install -y brave-origin

# Install Bitwarden desktop (password manager).
# Bitwarden has no dnf repo; this stable redirect always points at the latest
# signed RPM. It is not signed by a repo-trusted key, so skip gpgcheck here.
dnf5 install -y --nogpgcheck "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=rpm"

# Install Zoom (video conferencing) from the vendor's stable "latest" RPM URL.
rpm --import "https://zoom.us/linux/download/pubkey?version=5-12-6"
dnf5 install -y https://zoom.us/client/latest/zoom_x86_64.rpm

# Install Dropbox launcher/Nautilus integration from Dropbox's official Fedora repo.
# The package is a thin bootstrapper; the proprietary daemon self-installs into
# the user's ~/.dropbox-dist on first launch (atomic-friendly, no writes to /usr).
rpm --import https://linux.dropbox.com/fedora/rpm-public-key.asc
cat > /etc/yum.repos.d/dropbox.repo << 'EOF'
[Dropbox]
name=Dropbox Repository
baseurl=https://linux.dropbox.com/fedora/40/
gpgkey=https://linux.dropbox.com/fedora/rpm-public-key.asc
gpgcheck=1
enabled=1
EOF
dnf5 install -y nautilus-dropbox
rm -f /etc/yum.repos.d/dropbox.repo

# Install LibreOffice (office suite) from Fedora repositories. We pull the core
# apps plus the English langpack and GNOME integration. MS-Office-like defaults
# (OOXML save formats + ribbon UI) are applied via the .xcd overlay copied below.
dnf5 install -y \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress \
    libreoffice-draw \
    libreoffice-langpack-en \
    libreoffice-gtk3

# Apply MS-Office-like LibreOffice defaults system-wide. The registry directory
# is created by the libreoffice packages above, so this must run after install.
LO_REGISTRY="$(dirname "$(readlink -f /usr/bin/libreoffice)")/../lib/libreoffice/share/registry"
if [ ! -d "${LO_REGISTRY}" ]; then
    # Fall back to the conventional Fedora location.
    LO_REGISTRY="/usr/lib64/libreoffice/share/registry"
fi
mkdir -p "${LO_REGISTRY}"
cp /ctx/custom/libreoffice/blueforge-msoffice.xcd "${LO_REGISTRY}/"

# Replace default terminal
dnf5 remove -y ptyxis

# Prefer Ghostty as default terminal launcher target
mkdir -p /etc/xdg
cat > /etc/xdg/xdg-terminals.list << 'EOF'
com.mitchellh.ghostty.desktop
EOF

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

echo "::group:: Install Bundled GUI Apps (/opt)"

# These apps have no Fedora RPM/dnf repo, so we bake the vendor's official
# "latest" build into /opt and add a system .desktop launcher. They do not
# auto-update via dnf; they refresh when the image is rebuilt.

# --- Typora (markdown editor) -------------------------------------------------
# Official generic Linux tarball (unversioned "latest" URL).
curl -fSL -o /tmp/typora.tar.gz https://download.typora.io/linux/Typora-linux-x64.tar.gz
mkdir -p /opt/typora
tar -xzf /tmp/typora.tar.gz -C /opt/typora --strip-components=1
rm -f /tmp/typora.tar.gz
ln -sf /opt/typora/Typora /usr/bin/typora
cat > /usr/share/applications/typora.desktop << 'EOF'
[Desktop Entry]
Name=Typora
Comment=Minimal Markdown editor
Exec=/opt/typora/Typora %F
Icon=typora
Terminal=false
Type=Application
Categories=Office;TextEditor;Utility;
MimeType=text/markdown;text/x-markdown;
StartupWMClass=Typora
EOF
# Install Typora's icon if the tarball provides one.
for ic in /opt/typora/resources/assets/icon/icon_256x256.png /opt/typora/icon.png; do
    if [ -f "${ic}" ]; then
        mkdir -p /usr/share/icons/hicolor/256x256/apps
        cp "${ic}" /usr/share/icons/hicolor/256x256/apps/typora.png
        break
    fi
done

# --- Beeper (unified chat) ----------------------------------------------------
# Official AppImage (stable "latest" redirect). We extract it (no FUSE needed at
# runtime) into /opt and launch the bundled Electron app directly.
curl -fSL -o /tmp/beeper.AppImage \
    "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop"
chmod +x /tmp/beeper.AppImage
pushd /tmp > /dev/null
./beeper.AppImage --appimage-extract
popd > /dev/null
rm -rf /opt/beeper
mv /tmp/squashfs-root /opt/beeper
rm -f /tmp/beeper.AppImage
# The Electron sandbox helper must be setuid root to run unprivileged.
if [ -f /opt/beeper/chrome-sandbox ]; then
    chown root:root /opt/beeper/chrome-sandbox
    chmod 4755 /opt/beeper/chrome-sandbox
fi
# Pick the launcher entrypoint the AppImage shipped with.
BEEPER_EXEC=/opt/beeper/AppRun
[ -x /opt/beeper/beeper ] && BEEPER_EXEC=/opt/beeper/beeper
cat > /usr/share/applications/beeper.desktop << EOF
[Desktop Entry]
Name=Beeper
Comment=All your chats in one app
Exec=${BEEPER_EXEC} %U
Icon=beeper
Terminal=false
Type=Application
Categories=Network;InstantMessaging;Chat;
StartupWMClass=Beeper
EOF
# Install Beeper's bundled icon if present.
for ic in /opt/beeper/beeper.png /opt/beeper/.DirIcon; do
    if [ -f "${ic}" ]; then
        mkdir -p /usr/share/icons/hicolor/512x512/apps
        cp "${ic}" /usr/share/icons/hicolor/512x512/apps/beeper.png
        break
    fi
done

# --- UpNote (note-taking) -----------------------------------------------------
# Official AppImage (stable, unversioned "latest" redirect). UpNote ships no RPM
# or Flatpak, so we extract the AppImage (no FUSE needed at runtime) into /opt and
# launch the bundled Electron app directly — same approach as Beeper above.
curl -fSL -o /tmp/upnote.AppImage "https://download.getupnote.com/app/UpNote.AppImage"
chmod +x /tmp/upnote.AppImage
pushd /tmp > /dev/null
./upnote.AppImage --appimage-extract
popd > /dev/null
rm -rf /opt/upnote
mv /tmp/squashfs-root /opt/upnote
rm -f /tmp/upnote.AppImage
# The Electron sandbox helper must be setuid root to run unprivileged.
if [ -f /opt/upnote/chrome-sandbox ]; then
    chown root:root /opt/upnote/chrome-sandbox
    chmod 4755 /opt/upnote/chrome-sandbox
fi
# Pick the launcher entrypoint the AppImage shipped with.
UPNOTE_EXEC=/opt/upnote/AppRun
[ -x /opt/upnote/upnote ] && UPNOTE_EXEC=/opt/upnote/upnote
cat > /usr/share/applications/upnote.desktop << EOF
[Desktop Entry]
Name=UpNote
Comment=Note-taking app
Exec=${UPNOTE_EXEC} %U
Icon=upnote
Terminal=false
Type=Application
Categories=Office;Utility;
StartupWMClass=UpNote
EOF
# Install UpNote's bundled icon if present.
for ic in /opt/upnote/upnote.png /opt/upnote/.DirIcon \
          /opt/upnote/usr/share/icons/hicolor/512x512/apps/upnote.png; do
    if [ -f "${ic}" ]; then
        mkdir -p /usr/share/icons/hicolor/512x512/apps
        cp "${ic}" /usr/share/icons/hicolor/512x512/apps/upnote.png
        break
    fi
done

echo "::endgroup::"

echo "::group:: Configure automatic Homebrew bundle"

# Bluefin ships Homebrew (brew-setup.service) and keeps it updated
# (brew-update/brew-upgrade timers), but it does NOT auto-install our Brewfiles —
# that's normally a manual `ujust`/interactive step. This per-user service runs
# `brew bundle` on login so the curated toolchain (CLI tools + Vite+) is present
# out of the box, and re-runs only when the Brewfiles change after an image
# update (tracked by a content hash). It's idempotent and waits for Homebrew's
# first-boot setup to finish. Updates of installed packages are still handled by
# Bluefin's brew-upgrade timer.

install -Dm0755 /dev/stdin /usr/libexec/blueforge-brew-bundle << 'EOF'
#!/usr/bin/bash
# Auto-install BlueForge's Homebrew bundles (idempotent). Runs as the user.
set -uo pipefail

BREW=/home/linuxbrew/.linuxbrew/bin/brew

# Wait (up to ~10 min) for Homebrew to be ready — brew-setup.service extracts it
# on first boot, which can take a while on the very first login.
for _ in $(seq 1 60); do
    [ -x "${BREW}" ] && break
    sleep 10
done
[ -x "${BREW}" ] || exit 0

eval "$("${BREW}" shellenv)"

BREWFILES=(
    /usr/share/ublue-os/homebrew/default.Brewfile
    /usr/share/ublue-os/homebrew/fonts.Brewfile
)

# Only run when something changed (first boot, or Brewfiles updated by an image
# update) so routine logins stay fast.
STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/blueforge"
STAMP="${STATE_DIR}/brew-bundle.sha256"
mkdir -p "${STATE_DIR}"
NEW_SHA="$(cat "${BREWFILES[@]}" 2>/dev/null | sha256sum | cut -d' ' -f1)"
if [ -f "${STAMP}" ] && [ "$(cat "${STAMP}")" = "${NEW_SHA}" ]; then
    exit 0
fi

ok=true
for bf in "${BREWFILES[@]}"; do
    [ -f "${bf}" ] || continue
    brew bundle --file "${bf}" || ok=false
done

# Record the hash only after a fully clean run, so failures retry next login.
${ok} && printf '%s\n' "${NEW_SHA}" > "${STAMP}"
EOF

install -Dm0644 /dev/stdin /usr/lib/systemd/user/blueforge-brew-bundle.service << 'EOF'
[Unit]
Description=Install BlueForge Homebrew bundles (idempotent)
ConditionPathExists=/usr/share/ublue-os/homebrew/default.Brewfile

[Service]
Type=oneshot
ExecStart=/usr/libexec/blueforge-brew-bundle

[Install]
WantedBy=default.target
EOF

# Enable for every user (build-time equivalent of `systemctl --global enable`).
mkdir -p /usr/lib/systemd/user/default.target.wants
ln -sf ../blueforge-brew-bundle.service \
    /usr/lib/systemd/user/default.target.wants/blueforge-brew-bundle.service

echo "::endgroup::"

echo "::group:: System Configuration"

# Enable/disable systemd services
systemctl enable podman.socket
# Example: systemctl mask unwanted-service

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
