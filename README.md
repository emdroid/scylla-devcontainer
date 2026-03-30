# scylla-devcontainer

Reusable Dev Container setup for ScyllaDB development on Linux hosts (Fedora, Ubuntu), using the Scylla `dbuild` toolchain image.

The setup is intentionally lightweight and keeps machine-specific values out of version control.

## What this includes

- A Docker-based devcontainer configuration under `.devcontainer/`
- A sidecar workspace template: `scylla.code-workspace.example`
- A bootstrap script to generate local `.devcontainer/.env`, ensure `<sidecar-root>/.devcontainer` symlink, and create `<sidecar-root>/scylla.code-workspace`

The default sidecar layout is:

- `<sidecar-root>/scylla-devcontainer` (this repo)
- `<sidecar-root>/scylladb`
- `<sidecar-root>/python-driver`
- `<sidecar-root>/scylla-dtest`

Example:

- `/workspace/scylla-devcontainer`
- `/workspace/scylladb`
- `/workspace/python-driver`
- `/workspace/scylla-dtest`

## Quick start

1. Place this repo as a sidecar next to your checkouts.
2. Clone checkouts next to it (`scylladb`, optional `python-driver`, optional `scylla-dtest`).
3. Run bootstrap:

   ```bash
   ./scripts/gen-devcontainer-env.sh
   ```

   This command creates/updates:

   - `.devcontainer/.env`
   - `<sidecar-root>/.devcontainer` symlink to `scylla-devcontainer/.devcontainer`
   - `<sidecar-root>/scylla.code-workspace` (from `scylla.code-workspace.example` if missing)

   Run this once on the host first. After initial setup, re-running from inside the
   container is supported for refreshing `TOOLCHAIN_IMAGE`; the script updates only
   that key in `.devcontainer/.env` and preserves all other existing values.

4. Open `<sidecar-root>/scylla.code-workspace` in VS Code.
5. Reopen in container.

If bootstrap fails because `<sidecar-root>/.devcontainer` exists and is not a symlink,
follow the script instructions to move it aside and create the symlink.

## Toolchain image behavior

`scripts/gen-devcontainer-env.sh` reads the toolchain image from:

- `<sidecar-root>/scylladb/tools/toolchain/image` (preferred)

If that file is unavailable, it falls back to the default image baked into this repo.

This makes it easy to switch branches (including older branches that need older toolchains):

1. Switch branch in `<sidecar-root>/scylladb`
2. Re-run `./scripts/gen-devcontainer-env.sh`
3. Rebuild/reopen the container

## Workspace template behavior

- `scylla.code-workspace.example` is versioned.
- `<sidecar-root>/scylla.code-workspace` is local and should not be committed to any repo.
- The default template includes `scylla-devcontainer`, `scylladb`, `python-driver`, and `scylla-dtest`.
- Remove optional folders locally if you do not use them.

## Add more modules in VS Code

Use VS Code UI so each user can customize their own local workspace file:

1. Open `<sidecar-root>/scylla.code-workspace`.
2. Go to `File` -> `Add Folder to Workspace...`.
3. Select a sibling checkout under `<sidecar-root>`.
4. Save when prompted (`File` -> `Save Workspace`).

Because `<sidecar-root>/scylla.code-workspace` is outside this repo, these module additions stay local and are not committed here.

## Notes

- `.devcontainer/.env` is generated locally and is git-ignored.
- `<sidecar-root>/.devcontainer` should be a symlink to `scylla-devcontainer/.devcontainer`.
- `HOST_WORKSPACE_ROOT` is generated into `.devcontainer/.env` and used for parent-directory bind mount.
- When run inside a container, the script only updates `TOOLCHAIN_IMAGE` in `.devcontainer/.env` and leaves all other keys unchanged.
- The setup uses host networking and mounts `/var/run/docker.sock` for docker-in-docker workflows.
