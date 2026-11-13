FROM mcr.microsoft.com/devcontainers/base:ubuntu

# O build roda COM rede. Tudo que precisa de internet é instalado aqui, para que
# em runtime o container fique selado (só sai pelo Envoy).
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
    libncurses5-dev libffi-dev libgdbm6 libgdbm-dev uuid-dev curl git ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    # o agente não precisa (nem deve ter) sudo
    && rm -f /etc/sudoers.d/* && chmod u-s /usr/bin/sudo 2>/dev/null || true

USER vscode
ENV HOME=/home/vscode

RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/home/vscode/.local/bin:/home/vscode/.local/share/mise/shims:${PATH}"
RUN echo 'eval "$(mise activate bash)"' >> ~/.bashrc \
    && echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

ARG RUBY_VERSION=3.3.6
ARG NODE_VERSION=22
RUN mise use --global ruby@${RUBY_VERSION} node@${NODE_VERSION}

# Agente de IA (instalado no build, não em runtime).
RUN mise exec -- npm install -g @anthropic-ai/claude-code
