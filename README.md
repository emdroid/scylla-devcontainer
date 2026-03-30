# scylla-devcontainer

Reusable Dev Container setup for ScyllaDB development on Linux hosts (Fedora, Ubuntu), using the Scylla `dbuild` toolchain image.

The setup is intentionally lightweight and keeps machine-specific values out of version control.

## What this includes

- A Docker-based devcontainer configuration under `.devcontainer/`
- A multi-root VS Code workspace under `workspace/scylla.code-workspace`
- A script to generate local `.devcontainer/.env`

The workspace is designed for these sibling directories under `/workspace`:

- `scylladb`
- `python-driver`
- `scylla-dtest`

## Quick start

1. Clone repositories under `/workspace`:
   - `scylladb`
   - `python-driver`
   - `scylla-dtest`
2. Generate local environment file:

   ```bash
   ./scripts/gen-devcontainer-env.sh
   ```

3. Open `workspace/scylla.code-workspace` in VS Code.
4. Reopen in container.

## Toolchain image behavior

`scripts/gen-devcontainer-env.sh` reads the toolchain image from:

- `/workspace/scylladb/tools/toolchain/image` (preferred)

If that file is unavailable, it falls back to the default image baked into this repo.

This makes it easy to switch branches (including older branches that need older toolchains):

1. Switch branch in `/workspace/scylladb`
2. Re-run `./scripts/gen-devcontainer-env.sh`
3. Rebuild/reopen the container

## Notes

- `.devcontainer/.env` is generated locally and is git-ignored.
- The setup uses host networking and mounts `/var/run/docker.sock` for docker-in-docker workflows.
