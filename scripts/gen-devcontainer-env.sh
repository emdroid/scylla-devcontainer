#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sidecar_root="$(cd "${repo_root}/.." && pwd)"
repo_devcontainer_dir="${repo_root}/.devcontainer"
root_devcontainer_dir="${sidecar_root}/.devcontainer"
env_file="${repo_devcontainer_dir}/.env"
workspace_template="${repo_root}/scylla.code-workspace.example"
workspace_file="${sidecar_root}/scylla.code-workspace"
repo_dir_name="$(basename "${repo_root}")"

if [[ -L "${root_devcontainer_dir}" ]]; then
    current_target="$(readlink -f "${root_devcontainer_dir}")"
    expected_target="$(readlink -f "${repo_devcontainer_dir}")"
    if [[ "${current_target}" != "${expected_target}" ]]; then
        echo "Error: ${root_devcontainer_dir} points to ${current_target}, expected ${expected_target}." >&2
        echo "Fix it and re-run this script." >&2
        exit 1
    fi
    echo "Using existing ${root_devcontainer_dir} -> ${expected_target}"
elif [[ -e "${root_devcontainer_dir}" ]]; then
    echo "Error: ${root_devcontainer_dir} exists and is not a symlink." >&2
    echo "To migrate safely:" >&2
    echo "  mv \"${root_devcontainer_dir}\" \"${root_devcontainer_dir}.backup\"" >&2
    echo "  ln -s \"${repo_devcontainer_dir}\" \"${root_devcontainer_dir}\"" >&2
    echo "Then re-run this script." >&2
    exit 1
else
    ln -s "${repo_devcontainer_dir}" "${root_devcontainer_dir}"
    echo "Created ${root_devcontainer_dir} -> ${repo_devcontainer_dir}"
fi

dev_username="${USER:-devuser}"
dev_uid="$(id -u)"
dev_gid="$(id -g)"

docker_gid=""
if getent group docker >/dev/null 2>&1; then
    docker_gid="$(getent group docker | cut -d: -f3)"
elif [[ -S /var/run/docker.sock ]]; then
    docker_gid="$(stat -c %g /var/run/docker.sock)"
fi
docker_gid="${docker_gid:-996}"

default_toolchain_image="docker.io/scylladb/scylla-toolchain:fedora-43-20260304"
toolchain_file="${sidecar_root}/scylladb/tools/toolchain/image"
if [[ -f "${toolchain_file}" ]]; then
    toolchain_image="$(<"${toolchain_file}")"
else
    toolchain_image="${default_toolchain_image}"
fi

cat > "${env_file}" <<EOF
DEV_USERNAME=${dev_username}
DEV_UID=${dev_uid}
DEV_GID=${dev_gid}
DOCKER_GID=${docker_gid}
TOOLCHAIN_IMAGE=${toolchain_image}
HOST_WORKSPACE_ROOT=${sidecar_root}
EOF

echo "Wrote ${env_file}"

if [[ ! -f "${workspace_template}" ]]; then
    echo "Workspace template not found: ${workspace_template}" >&2
    exit 1
fi

if [[ -f "${workspace_file}" ]]; then
    echo "Keeping existing ${workspace_file}"
else
    sed "s|__SIDECAR_REPO_DIR__|${repo_dir_name}|g" "${workspace_template}" > "${workspace_file}"
    echo "Created ${workspace_file} from template"
fi

if grep -q "__SIDECAR_REPO_DIR__" "${workspace_file}"; then
    echo "Error: unresolved placeholder found in ${workspace_file}." >&2
    echo "Delete it and re-run this script to regenerate from template." >&2
    exit 1
fi

if [[ ! -d "${sidecar_root}/scylladb" ]]; then
    echo "Warning: expected sidecar checkout at ${sidecar_root}/scylladb" >&2
fi
