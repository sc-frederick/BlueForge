# vim: set ft=make :
#######################
### custom-system.just
#######################
## Host-first development, firmware containers, and system maintenance.

# Create the standard host workspace without changing existing repositories.
[group('Development')]
setup-workspace:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "${HOME}/Work"
    echo "Workspace ready: ${HOME}/Work"

# Report the tools that make up the BlueForge development environment.
[group('Development')]
blueforge-dev-status:
    #!/usr/bin/env bash
    set -u
    printf 'Workspace: %s\n\n' "${HOME}/Work"
    for tool in git gh podman distrobox devcontainer mise direnv cursor codex claude opencode t3; do
        if command -v "${tool}" >/dev/null 2>&1; then
            printf '  [ok]      %-14s %s\n' "${tool}" "$(command -v "${tool}")"
        else
            printf '  [missing] %s\n' "${tool}"
        fi
    done
    echo
    echo "Homebrew provisioning:"
    systemctl --user --no-pager --full status brew-preinstall.service blueforge-user-setup.service || true

# Create the shared, mutable firmware build environment. Project-specific
# devcontainers remain the better choice when a repository needs strict CI parity.
[group('Firmware')]
create-firmware-box:
    #!/usr/bin/env bash
    set -euo pipefail
    distrobox assemble create --file /usr/share/blueforge/distrobox/firmware.ini
    echo "Firmware box ready. Enter it with: ujust firmware-shell"

# Enter the shared firmware environment, creating it first when necessary.
[group('Firmware')]
firmware-shell:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! distrobox list --no-color 2>/dev/null | awk '{print $3}' | grep -qx blueforge-firmware; then
        distrobox assemble create --file /usr/share/blueforge/distrobox/firmware.ini
    fi
    exec distrobox enter blueforge-firmware

# Grant the current user access to serial devices used by development boards.
[group('Firmware')]
configure-firmware-access:
    #!/usr/bin/env bash
    set -euo pipefail
    current_user="$(id -un)"
    if id -nG "${current_user}" | tr ' ' '\n' | grep -qx dialout; then
        echo "${current_user} already has dialout access."
        exit 0
    fi
    pkexec bash -c '
        set -e
        target_user="$1"
        if ! grep -q "^dialout:" /etc/group; then
            grep "^dialout:" /usr/lib/group >> /etc/group
        fi
        usermod -aG dialout "${target_user}"
    ' bash "${current_user}"
    echo "Serial access configured. Log out and back in before using a board."
    echo "Board-vendor udev rules may still be required and should be baked into BlueForge."

# Remove unused rootless Podman data after explicit confirmation.
[group('Maintenance')]
clean-containers:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v gum >/dev/null 2>&1; then
        gum confirm "Remove unused Podman containers, images, and volumes?" || exit 0
    fi
    podman system prune --all --force --volumes

# Update the bootc deployment and optionally reboot into it.
[group('Maintenance')]
update-and-reboot:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo bootc upgrade
    if command -v gum >/dev/null 2>&1 && gum confirm "Reboot now to apply the update?"; then
        systemctl reboot
    else
        echo "Reboot later to apply the update."
    fi
