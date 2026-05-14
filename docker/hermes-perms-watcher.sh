#!/bin/bash
# Roda como root ANTES do entrypoint.sh dropar para 'hermes'.
# Mantém um processo em background (root) que corrige o owner dos arquivos
# criados pelo Paperclip (root) no volume compartilhado, tornando-os
# legíveis pelo hermes-agent (uid 10000/hermes). Intervalo: 30 segundos.

(while true; do
    chown -R hermes:hermes /opt/data 2>/dev/null
    sleep 30
done) &

exec /opt/hermes/docker/entrypoint.sh "$@"
