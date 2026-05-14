#!/bin/bash
set -e

# Keep permissions usable for files created by Paperclip in the shared volume.
chown -R hermes:hermes /opt/data 2>/dev/null || true
chmod -R u+rwX,g+rwX /opt/data 2>/dev/null || true

(while true; do
    chown -R hermes:hermes /opt/data 2>/dev/null || true
    chmod -R u+rwX,g+rwX /opt/data 2>/dev/null || true
    sleep 30
done) &

run_as_hermes() {
    su -s /bin/bash hermes -c "$1"
}

ensure_profile() {
    local profile="$1"

    if run_as_hermes "source /opt/hermes/.venv/bin/activate && cd /opt/hermes && HERMES_DATA_PATH=${HERMES_DATA_PATH:-/opt/data} hermes profile show $profile >/dev/null 2>&1"; then
        echo "[$profile] Hermes profile already exists."
        return 0
    fi

    echo "[$profile] Creating Hermes profile cloned from default..."
    run_as_hermes "source /opt/hermes/.venv/bin/activate && cd /opt/hermes && HERMES_DATA_PATH=${HERMES_DATA_PATH:-/opt/data} hermes profile create $profile --clone default" || \
    run_as_hermes "source /opt/hermes/.venv/bin/activate && cd /opt/hermes && HERMES_DATA_PATH=${HERMES_DATA_PATH:-/opt/data} hermes profile create $profile"
}

start_gateway() {
    local name="$1"
    local profile="$2"
    local port="$3"
    local key="$4"

    if [ -z "$port" ] || [ -z "$key" ]; then
        echo "[$name] Missing API_SERVER_PORT or API_SERVER_KEY; gateway skipped."
        return 0
    fi

    (
        while true; do
            echo "[$name] Starting Hermes gateway on port $port..."

            if [ -z "$profile" ]; then
                run_as_hermes "source /opt/hermes/.venv/bin/activate && cd /opt/hermes && API_SERVER_ENABLED=true API_SERVER_HOST=0.0.0.0 API_SERVER_PORT=$port API_SERVER_KEY=$key GATEWAY_ALLOW_ALL_USERS=${GATEWAY_ALLOW_ALL_USERS:-true} HERMES_DATA_PATH=${HERMES_DATA_PATH:-/opt/data} hermes gateway" || true
            else
                run_as_hermes "source /opt/hermes/.venv/bin/activate && cd /opt/hermes && API_SERVER_ENABLED=true API_SERVER_HOST=0.0.0.0 API_SERVER_PORT=$port API_SERVER_KEY=$key GATEWAY_ALLOW_ALL_USERS=${GATEWAY_ALLOW_ALL_USERS:-true} HERMES_DATA_PATH=${HERMES_DATA_PATH:-/opt/data} hermes -p $profile gateway" || true
            fi

            echo "[$name] Gateway exited; restarting in 60 seconds."
            sleep 60
        done
    ) &
}

ensure_profile "ens"
ensure_profile "imobiliaria-clementino"

start_gateway "core" "" "$HERMES_API_PORT_CORE" "$HERMES_API_KEY_CORE"
start_gateway "ens" "ens" "$HERMES_API_PORT_ENS" "$HERMES_API_KEY_ENS"
start_gateway "clementino" "imobiliaria-clementino" "$HERMES_API_PORT_CLEMENTINO" "$HERMES_API_KEY_CLEMENTINO"

wait
