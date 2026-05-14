#!/bin/bash

# ============================================================
# sync-config.sh - Hermes Configuration Watcher
# Monitora mudanças na configuração e reinicia os serviços.
# ============================================================

# Caminho para o arquivo de configuração (no Host)
# O Hermes pode salvar como config.yaml ou .env dentro da pasta de dados
CONFIG_DIR="./data/hermes"
SERVICES="hermes open-webui paperclip"
CHECK_INTERVAL=5

# Função para calcular o hash da pasta de config (detecta mudanças em qualquer arquivo)
get_config_hash() {
    find "$CONFIG_DIR" -maxdepth 1 -type f \( -name "config.yaml" -o -name ".env" -o -name "*.json" \) -exec md5sum {} + | md5sum | awk '{print $1}'
}

if [ ! -d "$CONFIG_DIR" ]; then
    echo "❌ Erro: Diretório $CONFIG_DIR não encontrado."
    exit 1
fi

LAST_HASH=$(get_config_hash)

echo "🔄 [$(date '+%H:%M:%S')] Hermes Watcher iniciado..."
echo "📁 Monitorando alterações em: $CONFIG_DIR"
echo "🐳 Serviços alvo: $SERVICES"

while true; do
    CURRENT_HASH=$(get_config_hash)

    if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
        echo "------------------------------------------------------------"
        echo "⚠️  [$(date '+%H:%M:%S')] Mudança de configuração detectada!"
        
        echo "🔄 Reiniciando serviços: $SERVICES..."
        
        # Usa o docker compose para reiniciar os serviços de forma limpa
        if docker compose restart $SERVICES; then
            echo "✅ Serviços reiniciados com sucesso."
            LAST_HASH="$CURRENT_HASH"
        else
            echo "❌ Erro ao reiniciar serviços. Verifique se você está na pasta do projeto."
        fi
        echo "------------------------------------------------------------"
    fi

    sleep "$CHECK_INTERVAL"
done
