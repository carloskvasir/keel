#!/bin/sh
# Gera /etc/envoy/envoy.yaml a partir do allowlist.yaml e inicia o Envoy.
set -eu

ALLOWLIST=/etc/envoy/allowlist.yaml
TMPL=/etc/envoy/envoy.yaml.tmpl
OUT=/tmp/envoy.yaml

# "- host" -> host, host:80, host:443 ; "- host:porta" -> host:porta
domains=$(sed -n 's/^[[:space:]]*-[[:space:]]*\([^[:space:]#]*\).*/\1/p' "$ALLOWLIST" | awk '
  index($0, ":") { printf "\"%s\",", $0; next }
  { printf "\"%s\",\"%s:80\",\"%s:443\",", $0, $0, $0 }
')
domains=${domains%,}

if [ -z "$domains" ]; then
  # allowlist vazia: nenhum domínio casa, tudo cai no Default Deny.
  domains='"keel.invalid"'
fi

sed "s|__ALLOWED_DOMAINS__|$domains|" "$TMPL" > "$OUT"
echo "keel: allowlist carregada: $domains"
exec envoy -c "$OUT" --log-level warn
