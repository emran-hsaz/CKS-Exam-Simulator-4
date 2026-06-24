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
kget() { kubectl get "$1" -n "$2" -o jsonpath="{$3}" 2>/dev/null; }

score=0; total=3
hdr "Q11 | SPDX Document and Remove Vulnerable Container (3 pts)"

images=$(kget deploy/multi-alpine default '.spec.template.spec.containers[*].image')
chk "Container alpine:3.19.1 has been removed from Deployment" \
  "$(echo "$images" | grep -qv '3.19.1' && echo true || echo false)" && ((score++))

count=$(kubectl get deploy multi-alpine -n default \
  -o jsonpath='{.spec.template.spec.containers}' 2>/dev/null | \
  python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)
chk "Deployment now has 2 containers (was 3)" \
  "$([ "$count" = "2" ] && echo true || echo false)" && ((score++))

chk "SPDX file /root/alpine.spdx exists" \
  "$([ -f /root/alpine.spdx ] && echo true || echo false)" && ((score++))

score_line $score $total
