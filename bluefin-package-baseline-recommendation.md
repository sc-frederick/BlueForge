# Recommended Baseline Selection (Balanced Daily Driver + Dev)

Generated: 2026-02-16

This is a curated starter subset from `bluefin-package-diff.md` to keep the image useful without pulling in every Bluefin extra.

Selection goals:
- Improve desktop usability for daily use
- Add practical shell/dev tooling
- Avoid hardware-specific drivers and heavy enterprise stacks by default

## Recommended to Add Now

### RPM (build-time, `build/10-build.sh`)

- [x] `fish`
- [x] `zsh`
- [x] `gnome-tweaks`
- [x] `gnome-shell-extension-gsconnect`
- [x] `nautilus-gsconnect`
- [x] `git-credential-libsecret`
- [x] `firewall-config`
- [x] `iwd`
- [x] `input-remapper`
- [x] `fastfetch`
- [x] `jetbrains-mono-fonts`
- [x] `nerd-fonts`

### Homebrew (runtime, `custom/brew/default.Brewfile`)

- [x] `atuin`
- [x] `direnv`
- [x] `mise`
- [x] `yq`
- [x] `tealdeer`
- [x] `trash-cli`
- [x] `micro`
- [x] `helix`
- [x] `nvim`
- [x] `claude-code`
- [x] `codex`
- [x] `copilot-cli`
- [x] `gemini-cli`
- [x] `kubectl`
- [x] `helm`
- [x] `k9s`
- [x] `kind`
- [x] `kubectx`
- [x] `syft`
- [x] `grype`
- [x] `nerdctl`

### Flatpak

- [x] No additional Bluefin-only Flatpaks needed right now (gap is zero).

## Recommended to Defer (Add Only If Needed)

### RPM Defer Buckets

- [ ] Hardware-specific kernel modules (`kmod-*`, `zfs`, `openrazer`, etc.)
- [ ] Enterprise auth/network stack (`adcli`, `sssd`, `realmd`, `krb5-*`)
- [ ] Full toolchain/debug packages (`*-devel`, `*-debuginfo`, compilers) unless building locally on host

### Homebrew Defer Buckets

- [ ] Large Kubernetes/platform suite (keep only `kubectl`/`helm`/`k9s`/`kind` initially)
- [ ] Extra IDE taps and Linux desktop app taps until you decide your editor stack
- [ ] Wallpaper/font mega-set unless you want full Bluefin visual parity

## Notes Before Applying

- `ripgrep` appears in Bluefin list, but your repo already includes `rg` in `custom/brew/default.Brewfile` (same tool formula alias).
- For build-time RPM additions, keep changes surgical and re-test with `just build`.
- After applying changes, update README "What Makes This BlueForge Different?" package sections.

## Optional Full Defer Lists

- Remaining RPMs not selected now: **203**
- Remaining Brew entries not selected now: **126**
- See `bluefin-package-diff.md` and `bluefin-package-diff-prioritized.md` for complete checklists.
