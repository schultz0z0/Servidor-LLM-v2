#!/bin/bash
# ============================================================
# openwebui-init.sh
# Cria a conta de admin automaticamente no primeiro boot.
# Roda a criação em background enquanto o servidor sobe normalmente.
# ============================================================

(
    echo "[init] Aguardando Open WebUI iniciar..."
    for i in $(seq 1 90); do
        if curl -sf http://localhost:8080/api/version > /dev/null 2>&1; then
            echo "[init] Open WebUI está pronto!"
            break
        fi
        sleep 2
    done

    # Cria a conta admin (o primeiro usuário vira admin automaticamente)
    if [ -n "$ADMIN_EMAIL" ] && [ -n "$ADMIN_PASSWORD" ]; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/api/v1/auths/signup \
            -H "Content-Type: application/json" \
            -d "{\"name\":\"${ADMIN_NAME:-Admin}\",\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}")

        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
            echo "[init] ✅ Conta admin criada com sucesso! (${ADMIN_EMAIL})"
        else
            echo "[init] Conta admin já existe ou signup desabilitado (HTTP ${HTTP_CODE}) — ignorando"
        fi
    fi
) &

# Inicia o servidor normalmente em foreground
cd /app/backend
exec bash start.sh
