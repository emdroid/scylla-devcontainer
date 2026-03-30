ARG TOOLCHAIN_IMAGE=docker.io/scylladb/scylla-toolchain:fedora-43-20260304
FROM ${TOOLCHAIN_IMAGE}
LABEL Description="Development Environment"

ARG USER_NAME=devuser
ARG USER_UID=1001
ARG USER_GID=${USER_UID}

RUN groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USER_NAME} -s /bin/bash

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/profile/.bash_history" \
    && echo "sudo chown -R ${USER_NAME}:${USER_NAME} /profile /ccache 2>/dev/null || true" >> "/home/${USER_NAME}/.bashrc" \
    && echo "${SNIPPET}" >> "/home/${USER_NAME}/.bashrc" \
    && ln -sf /profile/.tmux.conf "/home/${USER_NAME}/.tmux.conf"

RUN SSH_AGENT_SNIPPET='if [ -z "${SSH_AUTH_SOCK:-}" ]; then for sock in /tmp/vscode-ssh-auth-*.sock; do [ -S "$sock" ] && export SSH_AUTH_SOCK="$sock" && break; done; fi' \
    && echo "${SSH_AGENT_SNIPPET}" >> "/home/${USER_NAME}/.bashrc" \
    && echo "${SSH_AGENT_SNIPPET}" >> /root/.bashrc

RUN dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo \
    && dnf install -y \
        ca-certificates \
        ccache \
        curl \
        dnf5-plugins \
        gh \
        gzip \
        hostname \
        iputils \
        krb5-devel \
        parallel \
        procps-ng \
        ripgrep \
        strace \
        tmux \
        uv \
        vim \
        wget \
        which \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN echo ${USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME}

RUN mkdir -p \
        /home/${USER_NAME}/.config/gh \
        /home/${USER_NAME}/.config/opencode \
        /home/${USER_NAME}/.local/share/opencode \
        /home/${USER_NAME}/.local/state/opencode \
    && chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.config /home/${USER_NAME}/.local

USER ${USER_NAME}

RUN curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path

ENV PATH="/home/${USER_NAME}/.opencode/bin:${PATH}"

WORKDIR /workspace
