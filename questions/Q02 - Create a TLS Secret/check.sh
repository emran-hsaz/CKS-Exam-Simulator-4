#!/bin/bash
MARKS=3
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
exists() { kubectl get "$1" -n "$2" >/dev/null 2>&1 && echo true || echo false; }
kget()   { kubectl get "$1" -n "$2" -o jsonpath="{$3}" 2>/dev/null; }

score=0; total=3
hdr "Q2 | Create a TLS Secret (3 pts)"

chk "Secret tls-secret exists in namespace web-app" "$(exists secret/tls-secret web-app)" && ((score++))

stype=$(kget secret/tls-secret web-app '.type')
chk "Secret type is kubernetes.io/tls" "$([ "$stype" = "kubernetes.io/tls" ] && echo true || echo false)" && ((score++))

avail=$(kubectl get deploy web-app-deploy -n web-app -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
chk "Deployment web-app-deploy Pods are running" "$([ -n "$avail" ] && [ "$avail" -gt 0 ] 2>/dev/null && echo true || echo false)" && ((score++))

score_line $score $total
