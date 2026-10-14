#!/usr/bin/env bash

set -euo pipefail

readonly URL="${URL:-http://127.0.0.1/}"
readonly LOG_FILE="${LOG_FILE:-/var/log/nginx_check.log}"
readonly TIMEOUT="${TIMEOUT:-5}"
readonly EXPECTED_CODE="${EXPECTED_CODE:-200}"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

http_code=$(curl -s -o /dev/null -w "%{http_code}" \
    --max-time "$TIMEOUT" "$URL" 2>/dev/null || true)
http_code="${http_code:-000}"

if [[ "$http_code" == "$EXPECTED_CODE" ]]; then
    printf '%s SUCCESS http_code=%s url=%s\n' \
        "$timestamp" "$http_code" "$URL" | tee -a "$LOG_FILE"
    exit 0
else
    printf '%s FAILURE http_code=%s url=%s\n' \
        "$timestamp" "$http_code" "$URL" | tee -a "$LOG_FILE" >&2
    exit 1
fi
