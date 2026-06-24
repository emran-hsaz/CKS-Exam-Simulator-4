#!/bin/bash
MARKS=4
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}✔ CORRECT${NC}  $1"; }
fail() { echo -e "  ${RED}✘ WRONG${NC}    $1"; }
hdr()  { echo ""; echo -e "${CYAN}════════════════════════════════════════════════${NC}"; echo -e "${BOLD}$1${NC}"; echo -e "${CYAN}════════════════════════════════════════════════${NC}"; }
score_line() {
  local s=$1 t=$2 p=0; [ "$t" -gt 0 ] && p=$(( s * 100 / t ))
  if [ "$s" -eq "$t" ]; then echo -e "\n  ${GREEN}${BOLD}Score: $s/$t ($p%) — Perfect!${NC}\n"
  elif [ "$s" -gt 0 ]; then  echo -e "\n  ${YELLOW}${BOLD}Score: $s/$t ($p%) — Keep going!${NC}\n"
  else                        echo -e "\n  ${RED}${BOLD}Score: $s/$t ($p%) — Try again!${NC}\n"; fi
}
chk() { if [ "$2" = "true" ]; then pass "$1"; return 0; else fail "$1"; return 1; fi; }
kget() { kubectl get "$1" -n "$2" -o jsonpath="{$3}" 2>/dev/null; }

score=0; total=4
hdr "Q8 | Expose HTTPS Through Ingress with TLS (4 pts)"

chk "Ingress web-ingress exists in default namespace" \
  "$(kubectl get ingress web-ingress -n default >/dev/null 2>&1 && echo true || echo false)" && ((score++))

tls_secret=$(kget ingress/web-ingress default '.spec.tls[0].secretName')
chk "TLS secret = app-tls" "$([ "$tls_secret" = "app-tls" ] && echo true || echo false)" && ((score++))

host=$(kget ingress/web-ingress default '.spec.rules[0].host')
chk "Host = web.example.com" "$([ "$host" = "web.example.com" ] && echo true || echo false)" && ((score++))

svc=$(kget ingress/web-ingress default '.spec.rules[0].http.paths[0].backend.service.name')
chk "Backend service = web-svc" "$([ "$svc" = "web-svc" ] && echo true || echo false)" && ((score++))

score_line $score $total
