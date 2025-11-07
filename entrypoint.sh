#!/bin/sh
set -e

# Environment defaults
: "${PROXY_SERVER:=host.docker.internal}"
: "${PROXY_PORT:=1080}"
: "${PROXY_TYPE:=socks5}"

# Fill template
sed \
  -e "s/{{PROXY_SERVER}}/${PROXY_SERVER}/" \
  -e "s/{{PROXY_PORT}}/${PROXY_PORT}/" \
  -e "s/{{PROXY_TYPE}}/${PROXY_TYPE}/" \
  /etc/redsocks/redsocks.conf.template > /etc/redsocks/redsocks.conf

# Flush previous rules (important when restarting)
iptables -t nat -F

# Redirect ALL outbound TCP traffic to redsocks
iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-port 12345

echo "[redsocks] Transparent proxy active. Routing all TCP traffic through ${PROXY_TYPE}://${PROXY_SERVER}:${PROXY_PORT}"
exec redsocks -c /etc/redsocks/redsocks.conf
