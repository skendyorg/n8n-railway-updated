#!/bin/sh
set -eu
: "${TUNNEL_TOKEN:?TUNNEL_TOKEN must be set}"
coredns -conf /etc/coredns/Corefile &
dns_pid=$!
cloudflared tunnel --no-autoupdate run --dns-resolver-addrs 127.0.0.1:1053 &
tunnel_pid=$!
cleanup() {
    kill "$dns_pid" "$tunnel_pid" 2>/dev/null || true
    wait "$dns_pid" "$tunnel_pid" 2>/dev/null || true
}
trap 'cleanup; exit 0' INT TERM
# Railway restarts this container if either required process exits.
while kill -0 "$dns_pid" 2>/dev/null && kill -0 "$tunnel_pid" 2>/dev/null; do
    sleep 2
done
cleanup
exit 1
