#!/bin/bash
set -e

# ============================================================
# hermes-init.sh
# Gera /opt/data/.env a partir das variáveis de ambiente Docker
# para que o Hermes CLI consiga encontrar as API keys e configs.
# ============================================================

# O Docker Compose já injeta as variáveis através do 'env_file: - .env'.
# Deixamos o diretório livre para você usar o 'hermes setup' e salvar suas
# próprias configurações sem que o script apague nada nos reinícios.

exec "$@"
