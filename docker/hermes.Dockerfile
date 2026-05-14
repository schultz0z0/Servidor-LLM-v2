FROM ghcr.io/hostinger/hvps-hermes-agent:latest

USER root

# Atualizar repositórios e instalar pacotes base
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl git build-essential ca-certificates openssl wget gnupg chromium python3-pip python3-venv

# Fazer bootstrap do pip dentro do venv do Hermes (criado sem pip) e instalar o Playwright
RUN /opt/hermes/.venv/bin/python3 -m ensurepip --upgrade && \
    /opt/hermes/.venv/bin/python3 -m pip install --upgrade pip && \
    /opt/hermes/.venv/bin/python3 -m pip install playwright && \
    /opt/hermes/.venv/bin/python3 -m playwright install chromium && \
    /opt/hermes/.venv/bin/python3 -m playwright install-deps

# Script de init
COPY docker/hermes-init.sh /usr/local/bin/hermes-init.sh
RUN chmod +x /usr/local/bin/hermes-init.sh

# Watchdog: corrige owner dos arquivos criados pelo Paperclip (root) no volume compartilhado
# para que o hermes-agent (uid 10000/hermes) consiga ler — mantém Open WebUI funcionando
COPY docker/hermes-perms-watcher.sh /usr/local/bin/hermes-perms-watcher.sh
RUN chmod +x /usr/local/bin/hermes-perms-watcher.sh

COPY docker/hermes-all-in-one.sh /usr/local/bin/hermes-all-in-one.sh
RUN chmod +x /usr/local/bin/hermes-all-in-one.sh
