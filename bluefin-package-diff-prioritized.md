# Bluefin Gap Prioritized Review

Generated: 2026-02-16

This file reorganizes `bluefin-package-diff.md` into practical decision buckets so you can prune/add faster.

Legend:
- Keep checklist items checked `[x]` once you decide to add them
- Leave unchecked `[ ]` to skip for now

## Quick Triage

- Start with `Desktop UX` + `General Utilities` for user-facing improvements.
- Add `Dev Toolchain` and `Cloud/K8s` only if this image is for development workloads.
- Be cautious with `Hardware/Drivers` and `Enterprise/Network` unless you need them.

## RPM Missing from This Repo, Grouped by Priority

### Desktop UX (usually safe, user-visible)

- Count: **10**
- [ ] `adwaita-fonts-all`
- [ ] `gnome-shell-extension-gsconnect`
- [ ] `gnome-tweaks`
- [ ] `jetbrains-mono-fonts`
- [ ] `jetbrains-mono-fonts-all`
- [ ] `jetbrains-mono-nl-fonts`
- [ ] `nautilus-gsconnect`
- [ ] `nautilus-python`
- [ ] `nerd-fonts`
- [ ] `opendyslexic-fonts`

### General Utilities (often useful)

- Count: **153**
- [ ] `argyllcms`
- [ ] `argyllcms-data`
- [ ] `bcache-tools`
- [ ] `binutils`
- [ ] `boost-atomic`
- [ ] `boost-chrono`
- [ ] `boost-filesystem`
- [ ] `boost-program-options`
- [ ] `borgbackup`
- [ ] `cryfs`
- [ ] `davfs2`
- [ ] `dbus-daemon`
- [ ] `dbus-tools`
- [ ] `dbus-x11`
- [ ] `fastfetch`
- [ ] `firewall-config`
- [ ] `fish`
- [ ] `foo2zjs`
- [ ] `foomatic-db-filesystem`
- [ ] `fuse-encfs`
- [ ] `generic-logos`
- [ ] `git`
- [ ] `git-credential-libsecret`
- [ ] `glow`
- [ ] `gsl`
- [ ] `gtksourceview4`
- [ ] `gum`
- [ ] `ifuse`
- [ ] `input-remapper`
- [ ] `iwd`
- [ ] `lcms`
- [ ] `lcms-libs`
- [ ] `libXScrnSaver`
- [ ] `libell`
- [ ] `libgda`
- [ ] `libgda-sqlite`
- [ ] `libgit2`
- [ ] `libi2c`
- [ ] `libkadm5`
- [ ] `libnvpair3`
- [ ] `liboping`
- [ ] `libssh2`
- [ ] `libuutil3`
- [ ] `libvarlink`
- [ ] `libxcrypt-compat`
- [ ] `libzpool6`
- [ ] `llhttp`
- [ ] `lm_sensors`
- [ ] `lsb_release`
- [ ] `m4`
- [ ] `ncurses-term`
- [ ] `neon`
- [ ] `openssh-askpass`
- [ ] `pcp-conf`
- [ ] `pcp-libs`
- [ ] `perl-AutoLoader`
- [ ] `perl-B`
- [ ] `perl-Carp`
- [ ] `perl-Class-Struct`
- [ ] `perl-Data-Dumper`
- [ ] `perl-Digest`
- [ ] `perl-Digest-MD5`
- [ ] `perl-DynaLoader`
- [ ] `perl-Encode`
- [ ] `perl-Errno`
- [ ] `perl-Error`
- [ ] `perl-Exporter`
- [ ] `perl-Fcntl`
- [ ] `perl-File-Basename`
- [ ] `perl-File-Path`
- [ ] `perl-File-Temp`
- [ ] `perl-File-stat`
- [ ] `perl-FileHandle`
- [ ] `perl-Getopt-Long`
- [ ] `perl-Getopt-Std`
- [ ] `perl-Git`
- [ ] `perl-HTTP-Tiny`
- [ ] `perl-IO`
- [ ] `perl-IO-Socket-IP`
- [ ] `perl-IO-Socket-SSL`
- [ ] `perl-IPC-Open3`
- [ ] `perl-MIME-Base32`
- [ ] `perl-MIME-Base64`
- [ ] `perl-NDBM_File`
- [ ] `perl-Net-SSLeay`
- [ ] `perl-POSIX`
- [ ] `perl-PathTools`
- [ ] `perl-Pod-Escapes`
- [ ] `perl-Pod-Perldoc`
- [ ] `perl-Pod-Simple`
- [ ] `perl-Pod-Usage`
- [ ] `perl-Scalar-List-Utils`
- [ ] `perl-SelectSaver`
- [ ] `perl-Socket`
- [ ] `perl-Storable`
- [ ] `perl-Symbol`
- [ ] `perl-Term-ANSIColor`
- [ ] `perl-Term-Cap`
- [ ] `perl-TermReadKey`
- [ ] `perl-Text-ParseWords`
- [ ] `perl-Text-Tabs+Wrap`
- [ ] `perl-Time-Local`
- [ ] `perl-URI`
- [ ] `perl-base`
- [ ] `perl-constant`
- [ ] `perl-if`
- [ ] `perl-interpreter`
- [ ] `perl-lib`
- [ ] `perl-libnet`
- [ ] `perl-libs`
- [ ] `perl-locale`
- [ ] `perl-mro`
- [ ] `perl-overload`
- [ ] `perl-overloading`
- [ ] `perl-parent`
- [ ] `perl-podlators`
- [ ] `perl-vars`
- [ ] `powertop`
- [ ] `pv`
- [ ] `python3-annotated-types`
- [ ] `python3-dns`
- [ ] `python3-email-validator`
- [ ] `python3-llfuse`
- [ ] `python3-msgpack`
- [ ] `python3-pip`
- [ ] `python3-psutil`
- [ ] `python3-pydantic`
- [ ] `python3-pydantic+email`
- [ ] `python3-pydantic-core`
- [ ] `python3-pydbus`
- [ ] `python3-pygit2`
- [ ] `python3-setuptools`
- [ ] `python3-typing-extensions`
- [ ] `python3-typing-inspection`
- [ ] `rclone`
- [ ] `restic`
- [ ] `runc`
- [ ] `setools-console`
- [ ] `spdlog`
- [ ] `sysstat`
- [ ] `tailscale`
- [ ] `tinyxml2`
- [ ] `usbip`
- [ ] `uupd`
- [ ] `waypipe`
- [ ] `xdg-terminal-exec`
- [ ] `xmlrpc-c`
- [ ] `xmlrpc-c-client`
- [ ] `xrandr`
- [ ] `xset`
- [ ] `yyjson`
- [ ] `zenity`
- [ ] `zsh`

### Dev Toolchain (bigger footprint)

- Count: **17**
- [ ] `bison`
- [ ] `cmake-filesystem`
- [ ] `elfutils-libelf-devel`
- [ ] `flatpak-debuginfo`
- [ ] `flatpak-debugsource`
- [ ] `flatpak-libs-debuginfo`
- [ ] `flatpak-session-helper-debuginfo`
- [ ] `flex`
- [ ] `gcc`
- [ ] `glibc-devel`
- [ ] `kernel-devel-matched`
- [ ] `kernel-headers`
- [ ] `libxcrypt-devel`
- [ ] `libzstd-devel`
- [ ] `make`
- [ ] `openssl-devel`
- [ ] `zlib-ng-compat-devel`

### Containers/Virtualization (specialized)

- Count: **1**
- [ ] `containerd`

### Hardware/Drivers (device-specific)

- Count: **16**
- [ ] `ddcutil`
- [ ] `evtest`
- [ ] `framework-laptop-kmod-common`
- [ ] `i2c-tools`
- [ ] `igt-gpu-tools`
- [ ] `kmod-framework-laptop`
- [ ] `kmod-openrazer`
- [ ] `kmod-v4l2loopback`
- [ ] `kmod-xone`
- [ ] `kmod-zfs`
- [ ] `libzfs6`
- [ ] `openrazer-kmod-common`
- [ ] `python3-pyzfs`
- [ ] `v4l2loopback`
- [ ] `xone-kmod-common`
- [ ] `zfs`

### Enterprise/Network/Auth (org-specific)

- Count: **18**
- [ ] `adcli`
- [ ] `krb5-pkinit`
- [ ] `krb5-workstation`
- [ ] `libnetapi`
- [ ] `libsss_autofs`
- [ ] `oddjob`
- [ ] `oddjob-mkhomedir`
- [ ] `samba`
- [ ] `samba-common-tools`
- [ ] `samba-dcerpc`
- [ ] `samba-ldb-ldap-modules`
- [ ] `samba-libs`
- [ ] `samba-winbind`
- [ ] `samba-winbind-clients`
- [ ] `samba-winbind-modules`
- [ ] `sssd-ad`
- [ ] `sssd-common-pac`
- [ ] `sssd-krb5`

## Homebrew Missing from This Repo, Grouped by Priority

### Editors/IDEs (high impact for dev workflow)

- Count: **19**
- [ ] `helix`
- [ ] `micro`
- [ ] `microcks/tap/microcks-cli`
- [ ] `nvim`
- [ ] `ublue-os/experimental-tap/clion-linux`
- [ ] `ublue-os/experimental-tap/cursor-linux`
- [ ] `ublue-os/experimental-tap/datagrip-linux`
- [ ] `ublue-os/experimental-tap/dataspell-linux`
- [ ] `ublue-os/experimental-tap/emacs-app-linux`
- [ ] `ublue-os/experimental-tap/goland-linux`
- [ ] `ublue-os/experimental-tap/intellij-idea-linux`
- [ ] `ublue-os/experimental-tap/phpstorm-linux`
- [ ] `ublue-os/experimental-tap/pycharm-linux`
- [ ] `ublue-os/experimental-tap/rider-linux`
- [ ] `ublue-os/experimental-tap/rubymine-linux`
- [ ] `ublue-os/experimental-tap/rustrover-linux`
- [ ] `ublue-os/experimental-tap/webstorm-linux`
- [ ] `ublue-os/tap/visual-studio-code-linux`
- [ ] `ublue-os/tap/vscodium-linux`

### AI CLIs (optional, fast-moving)

- Count: **14**
- [ ] `aichat`
- [ ] `anomalyco/tap/opencode`
- [ ] `block-goose-cli`
- [ ] `claude-code`
- [ ] `codex`
- [ ] `gemini-cli`
- [ ] `kimi-cli`
- [ ] `llm`
- [ ] `mistral-vibe`
- [ ] `qwen-code`
- [ ] `ublue-os/experimental-tap/opencode-desktop-linux`
- [ ] `ublue-os/tap/goose-linux`
- [ ] `ublue-os/tap/linux-mcp-server`
- [ ] `whisper-cpp`

### General CLI tools

- Count: **64**
- [ ] `argo`
- [ ] `artifacthub/cmd/ah`
- [ ] `atlantis`
- [ ] `atuin`
- [ ] `bash-preexec`
- [ ] `buildpacks/tap/pack`
- [ ] `c7n`
- [ ] `carvel-dev/carvel/imgpkg`
- [ ] `carvel-dev/carvel/kapp`
- [ ] `carvel-dev/carvel/kbld`
- [ ] `carvel-dev/carvel/kctrl`
- [ ] `carvel-dev/carvel/kwt`
- [ ] `carvel-dev/carvel/vendir`
- [ ] `carvel-dev/carvel/ytt`
- [ ] `cdk8s`
- [ ] `charmbracelet/tap/crush`
- [ ] `chezmoi`
- [ ] `cmctl`
- [ ] `copilot-cli`
- [ ] `coredns`
- [ ] `cortex`
- [ ] `cri-tools`
- [ ] `dapr/tap/dapr-cli`
- [ ] `devspace`
- [ ] `direnv`
- [ ] `dysk`
- [ ] `envoy`
- [ ] `falco`
- [ ] `grpc`
- [ ] `harbor-cli`
- [ ] `kcl-lang/tap/kcl`
- [ ] `kitops-ml/kitops/kitops`
- [ ] `kn`
- [ ] `ko`
- [ ] `kptdev/kpt/kpt`
- [ ] `kumactl`
- [ ] `kwctl`
- [ ] `kyverno`
- [ ] `litmusctl`
- [ ] `mesheryctl`
- [ ] `mise`
- [ ] `mods`
- [ ] `nats-server`
- [ ] `notation`
- [ ] `opa`
- [ ] `openfga`
- [ ] `opentelemetry-cpp`
- [ ] `porter`
- [ ] `ripgrep`
- [ ] `swiftformat`
- [ ] `swiftlint`
- [ ] `swiftly`
- [ ] `tealdeer`
- [ ] `tiup`
- [ ] `trash-cli`
- [ ] `tremor-runtime`
- [ ] `ublue-os/tap/antigravity-linux`
- [ ] `ublue-os/tap/jetbrains-toolbox-linux`
- [ ] `ublue-os/tap/lm-studio-linux`
- [ ] `ugrep`
- [ ] `uutils-coreutils`
- [ ] `valkyrie00/bbrew/bbrew`
- [ ] `virtctl`
- [ ] `yq`

### Containers/DevOps tooling

- Count: **10**
- [ ] `dagger`
- [ ] `devcontainer`
- [ ] `grype`
- [ ] `k0sproject/tap/k0sctl`
- [ ] `lima`
- [ ] `nerdctl`
- [ ] `ramalama`
- [ ] `syft`
- [ ] `wasmcloud/wasmcloud/wash`
- [ ] `wasmedge`

### Cloud/K8s toolchain (heavy/specialized)

- Count: **26**
- [ ] `argocd`
- [ ] `cilium-cli`
- [ ] `crossplane`
- [ ] `etcd`
- [ ] `flux`
- [ ] `helm`
- [ ] `istioctl`
- [ ] `k3d`
- [ ] `k3sup`
- [ ] `k8sgpt`
- [ ] `k9s`
- [ ] `karmadactl`
- [ ] `kind`
- [ ] `kubectl`
- [ ] `kubectl-cnpg`
- [ ] `kubectx`
- [ ] `kubernetes-cli`
- [ ] `kubescape`
- [ ] `kubevela`
- [ ] `linkerd`
- [ ] `minikube`
- [ ] `operator-sdk`
- [ ] `prometheus`
- [ ] `telepresenceio/telepresence/telepresence-oss`
- [ ] `thanos`
- [ ] `vitess`

### Fonts/Wallpapers (cosmetic)

- Count: **14**
- [ ] `aurora-wallpapers`
- [ ] `bazzite-wallpapers`
- [ ] `bluefin-wallpapers`
- [ ] `bluefin-wallpapers-extra`
- [ ] `font-0xproto-nerd-font`
- [ ] `font-blex-mono-nerd-font`
- [ ] `font-caskaydia-mono-nerd-font`
- [ ] `font-comic-shanns-mono-nerd-font`
- [ ] `font-droid-sans-mono-nerd-font`
- [ ] `font-go-mono-nerd-font`
- [ ] `font-sauce-code-pro-nerd-font`
- [ ] `font-source-code-pro`
- [ ] `font-ubuntu-nerd-font`
- [ ] `framework-wallpapers`

## Flatpak Gap

- Bluefin has no additional Flatpak app IDs beyond your current manifest.
