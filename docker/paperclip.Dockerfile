FROM ghcr.io/hostinger/hvps-paperclip:latest

USER root

# Atualizar repositórios e instalar pacotes base
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl git build-essential ca-certificates openssl wget gnupg chromium python3-pip python3-venv

# Instalar dependências Python e Playwright conforme documentação
RUN pip3 install playwright --break-system-packages && \
    playwright install chromium && \
    playwright install-deps

# Instalar Hermes Agent CLI localmente
RUN pip3 install git+https://github.com/NousResearch/hermes-agent.git --break-system-packages

# Garantir que o Hermes CLI encontre o diretório compartilhado (.hermes)
# independente de qual usuário o Paperclip esteja rodando
RUN ln -sf /paperclip/.hermes /root/.hermes
