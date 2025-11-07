#!/bin/sh
set -e

# Environment defaults
: "${PROXY_SERVER:=127.0.0.1}"
: "${PROXY_PORT:=1080}"
: "${PROXY_TYPE:=socks5}"

# Build redsocks config
sed \
  -e "s/{{PROXY_SERVER}}/${PROXY_SERVER}/" \
  -e "s/{{PROXY_PORT}}/${PROXY_PORT}/" \
  -e "s/{{PROXY_TYPE}}/${PROXY_TYPE}/" \
  /etc/redsocks/redsocks.conf.template > /etc/redsocks/redsocks.conf

# Flush old rules
iptables -t nat -F

# 1) **Do NOT proxy the upstream SOCKS server itself**
iptables -t nat -A OUTPUT -p tcp -d ${PROXY_SERVER} --dport ${PROXY_PORT} -j RETURN

# 2) Do NOT proxy local networks (optional but recommended)
iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1/8 -j RETURN
iptables -t nat -A OUTPUT -p tcp -d 10.0.0.0/8 -j RETURN
iptables -t nat -A OUTPUT -p tcp -d 172.16.0.0/12 -j RETURN
iptables -t nat -A OUTPUT -p tcp -d 192.168.0.0/16 -j RETURN

# 3) Proxy everything else
iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-port 12345

echo "[redsocks] Transparent proxy active → Routing all outbound TCP via ${PROXY_TYPE}://${PROXY_SERVER}:${PROXY_PORT}"
exec redsocks -c /etc/redsocks/redsocks.conf
