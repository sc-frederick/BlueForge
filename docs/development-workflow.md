# BlueForge Development Workflow

BlueForge is host-first and container-capable. Repositories remain ordinary
directories under `~/Work`; a project opts into a container only when isolation
or reproducibility provides a concrete benefit.

## Default workflow

```bash
cd ~/Work
git clone git@github.com:OWNER/PROJECT.git
cd PROJECT
opencode     # or t3
```

OpenCode and T3 Code are provisioned for the user. They are not duplicated
inside every project container. Authentication is still per-user and
intentionally remains outside the OS image.

## The three layers

### 1. BlueForge host

Human-facing applications and universal tools belong on the host:

- editors and coding agents;
- Git, GitHub CLI, Podman, Distrobox, and the devcontainer CLI;
- `mise`, `direnv`, and `uv` for lightweight project isolation;
- USB permissions, udev rules, drivers, and system services.

### 2. Repository

Every repository should describe how it is built instead of depending on an
undocumented workstation state. Prefer a small, tool-independent interface:

```text
project/
├── AGENTS.md
├── Justfile
├── mise.toml
├── package/toolchain lockfiles
└── .devcontainer/        # only when the project needs it
```

Recommended commands are `just setup`, `just dev`, `just test`, and
`just build`. An AI agent can use those commands without knowing whether their
implementation is native, Podman-based, or a devcontainer.

Use `AGENTS.md` for repository-specific conventions, build commands, tests,
generated files, and hardware restrictions. Keep personal preferences in the
tool's user configuration rather than committing them to every repository.

### 3. Optional project container

Add `.devcontainer/devcontainer.json` when a repository has conflicting system
dependencies, multiple backing services, a legacy SDK, or a strong need for CI
parity. A local devcontainer normally bind-mounts the existing repository; it
does not require moving the source out of `~/Work`.

Good devcontainer candidates include:

- applications with PostgreSQL, Redis, queues, or several services;
- team projects that must share an exact compiler or SDK;
- legacy toolchains that conflict with modern host packages;
- builds whose container definition is also exercised in CI.

Simple Node, Python, Go, and Rust repositories usually need only a lockfile plus
`mise`, `uv`, or the language's standard toolchain file.

## First-login behavior

Bluefin's `brew-preinstall.service` reconciles
`/usr/share/ublue-os/homebrew/preinstall.d/blueforge.Brewfile`. BlueForge then:

1. creates `~/Work`;
2. installs the official T3 Code npm package;
3. refreshes moving npm packages at most once per week.

Inspect the result with:

```bash
ujust blueforge-dev-status
```

Reconcile it manually with:

```bash
ujust install-blueforge-tools
```

## Practical policy

- Start native in `~/Work`.
- Add pinned project runtimes before adding a container.
- Add a devcontainer when it removes more friction than it introduces.
- Put stable entry points in `just`, regardless of the underlying environment.
- Never use `rpm-ostree install`; system integration belongs in the image build.
