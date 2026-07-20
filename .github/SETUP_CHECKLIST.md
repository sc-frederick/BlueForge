# BlueForge Release Checklist

## Repository

- [x] BlueForge naming and GHCR paths are set.
- [x] Standard and Nvidia installer configurations target this repository.
- [x] Signing is optional and disabled by default.
- [ ] Protect `main` and require pull-request validation.
- [ ] Confirm GitHub Actions has package write permission.

## Before a pull request

- [ ] Update README package/configuration notes and date.
- [ ] Run ShellCheck on `build/*.sh` and `custom/scripts/*.sh`.
- [ ] Validate modified YAML and TOML files.
- [ ] Run `just --list` and Justfile format checks.
- [ ] Review Brewfile and Flatpak validation results.
- [ ] Use a Conventional Commit title.

## Before publishing

- [ ] Test the image in a VM or on a non-critical machine.
- [ ] Verify first-login Homebrew and BlueForge user setup services.
- [ ] Run `ujust blueforge-dev-status`.
- [ ] Verify rollback and the standard update path.

## Optional production hardening

- [ ] Generate a Cosign key pair.
- [ ] Store the private key only in `SIGNING_SECRET`.
- [ ] Enable image signing and optional SBOM attestation.
- [ ] Never commit `cosign.key`.
