#!/bin/bash
set -e

chown -R hermes:hermes /opt/data 2>/dev/null || true
chmod -R u+rwX,g+rwX /opt/data 2>/dev/null || true

run_as_hermes() {
    su -s /bin/bash hermes -c "$1"
}

run_as_hermes "source /opt/hermes/.venv/bin/activate && cd /opt/hermes && HERMES_DATA_PATH=${HERMES_DATA_PATH:-/opt/data} hermes kanban init || true"

exec su -s /bin/bash hermes -c "source /opt/hermes/.venv/bin/activate && cd /opt/hermes && HERMES_DATA_PATH=${HERMES_DATA_PATH:-/opt/data} hermes dashboard --host 0.0.0.0 --port ${HERMES_KANBAN_PORT:-9119} --no-open --insecure"
