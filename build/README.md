# BlueForge Image Build

`10-build.sh` is the single image mutation entry point invoked by the
Containerfile. BlueForge intentionally keeps this layer small and inherits the
desktop, Homebrew, Podman, Distrobox, and update infrastructure from Bluefin.

Use the build script for system-integrated software only:

- RPM packages and temporary third-party repositories;
- systemd services, policies, drivers, firmware, and udev rules;
- files under `/usr`, `/etc`, or immutable `/opt`;
- declarative files copied from `custom/`.

Do not put user CLI tools or project SDKs here. Automatic user tools belong in
`custom/brew/preinstall.d/`, optional tools in another Brewfile, and project
dependencies in the repository or a container.

## Rules

- Use `dnf5 install -y`; never use `dnf`, `yum`, or `rpm-ostree install`.
- Install Fedora packages before enabling a COPR.
- Use `copr_install_isolated` for COPR packages.
- Remove third-party repository files after installing their packages.
- Keep downloads and cleanup in the same image layer.
- Run ShellCheck after every shell change.

The `.example` scripts are references only. The Containerfile currently invokes
only `10-build.sh`; adding another active numbered script also requires an
explicit Containerfile or runner change.

## Validation

```bash
shellcheck -x build/*.sh custom/scripts/*.sh
bash -n build/10-build.sh custom/scripts/blueforge-user-setup.sh
just --list
```
