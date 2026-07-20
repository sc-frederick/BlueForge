# Firmware Development on BlueForge

Firmware development is intentionally hybrid. Containers are excellent for
compilers and SDKs; the host is the reliable place for changing USB devices,
serial permissions, vendor udev rules, and graphical debug tools.

## Low-friction shared environment

Create BlueForge's optional Distrobox once:

```bash
ujust create-firmware-box
ujust firmware-shell
```

The container shares the normal home directory, so a repository at
`~/Work/board-firmware` is available at the same path inside the box. It contains
common C/C++ build tools, CMake, Ninja, GDB, OpenOCD, DFU utilities, AVR tools,
and a serial terminal. Install vendor SDKs inside this mutable box when they do
not warrant a project-specific container.

Configure serial access once on the host:

```bash
ujust configure-firmware-access
```

Log out and back in after the group change. Development boards may also require
vendor-specific udev rules; those should be added to the BlueForge image rather
than installed imperatively on a running bootc system.

## Recommended project interface

Expose the environment through stable repository commands:

```just
build:
    distrobox enter blueforge-firmware -- cmake --build build

flash:
    # Prefer a host-side programmer when USB passthrough is unreliable.
    openocd -f interface/cmsis-dap.cfg -f target/example.cfg -c "program build/app.elf verify reset exit"

monitor PORT="/dev/ttyACM0":
    picocom {{ PORT }}
```

The exact commands belong to the project. AI coding tools can then run
`just build` or `just test` without carrying environment-specific prompting.

## When to add a devcontainer

Use a repository-local devcontainer instead of the shared Distrobox when:

- the SDK/compiler version must be identical for every contributor;
- CI should build the exact same image;
- two firmware projects need incompatible toolchains;
- setup requires several services or complex environment variables.

Keep the source in `~/Work` even then. Cursor can reopen that directory in its
container, while host-side Codex, Claude Code, OpenCode, or T3 Code can call the
same `just` wrappers.

## Hardware boundary

Prefer this order:

1. build and test in the container;
2. write artifacts into the repository's `build/` directory;
3. flash, monitor, and debug from the host;
4. pass specific devices into a container only when the toolchain requires it.

Avoid privileged containers as a default. Device-specific access is easier to
audit and less likely to hide missing host permissions.
