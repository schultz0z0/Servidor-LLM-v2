FROM ghcr.io/open-webui/open-webui:main

USER root

# Atualizar repositórios e instalar pacotes base
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl git build-essential ca-certificates openssl wget gnupg chromium python3-pip python3-venv

# Instalar dependências Python e Playwright conforme documentação
RUN pip3 install playwright --break-system-packages && \
    playwright install chromium && \
    playwright install-deps

# Script de auto-provisionamento do admin no primeiro boot
COPY docker/openwebui-init.sh /usr/local/bin/openwebui-init.sh
RUN chmod +x /usr/local/bin/openwebui-init.sh

CMD ["bash", "/usr/local/bin/openwebui-init.sh"]
