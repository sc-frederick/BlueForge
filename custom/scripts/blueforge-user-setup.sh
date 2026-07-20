#!/usr/bin/env bash

# Complete user-owned setup that cannot be baked into an immutable bootc image.
set -euo pipefail

readonly MANIFEST="/usr/share/blueforge/npm/global-packages.txt"
readonly STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/blueforge"
readonly STAMP="${STATE_DIR}/npm-global.sha256"
readonly BREW_BIN="/var/home/linuxbrew/.linuxbrew/bin/brew"

# Preserve the normal workstation model: repositories live directly on the
# host and may opt into containers individually.
mkdir -p "${HOME}/Work" "${STATE_DIR}"

[[ -f "${MANIFEST}" ]] || exit 0

# brew-preinstall.service normally finishes first. The short retry also handles
# the first login, when Homebrew itself may still be completing setup.
for _ in {1..60}; do
    [[ -x "${BREW_BIN}" ]] && break
    sleep 2
done
[[ -x "${BREW_BIN}" ]] || {
    echo "blueforge-user-setup: Homebrew is not ready; retrying next login"
    exit 0
}

eval "$("${BREW_BIN}" shellenv)"
command -v npm >/dev/null 2>&1 || {
    echo "blueforge-user-setup: npm is not ready; retrying next login"
    exit 0
}

current_hash="$(sha256sum "${MANIFEST}" | cut -d' ' -f1)"

# Apply manifest changes immediately and refresh moving @latest packages once a
# week. Routine logins take the fast path without contacting npm.
if [[ -f "${STAMP}" ]] \
    && [[ "$(cat "${STAMP}")" == "${current_hash}" ]] \
    && [[ -n "$(find "${STAMP}" -mtime -7 -print -quit)" ]]; then
    exit 0
fi

mapfile -t packages < <(sed -E '/^[[:space:]]*(#|$)/d' "${MANIFEST}")
if [[ ${#packages[@]} -eq 0 ]]; then
    printf '%s\n' "${current_hash}" > "${STAMP}"
    exit 0
fi

echo "blueforge-user-setup: installing npm tools: ${packages[*]}"
npm install --global "${packages[@]}"
printf '%s\n' "${current_hash}" > "${STAMP}"
