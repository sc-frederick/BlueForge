# Contributing to BlueForge

BlueForge is a thin downstream of Bluefin. Changes should stay focused on the
developer workstation described in the README; improvements that belong to all
Bluefin users should be proposed upstream.

## Workflow

1. Create a development branch; do not push directly to `main`.
2. Keep system packages, automatic user tools, optional tools, and project
   dependencies in their documented layers.
3. Update the README's “What Makes This BlueForge Different?” section when
   packages or configuration change.
4. Run the relevant validation commands from `AGENTS.md`.
5. Use a Conventional Commit title such as `feat: add firmware workspace`.
6. Open a pull request and merge only after validation succeeds.

External Bluefin architecture guidance is available in the
[Bluefin contributing guide](https://docs.projectbluefin.io/contributing/).
