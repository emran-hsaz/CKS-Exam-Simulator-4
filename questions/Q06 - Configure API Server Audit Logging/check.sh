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

APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
score=0; total=4
hdr "Q6 | Configure API Server Audit Logging (4 pts)"

chk "--audit-policy-file configured in API server" \
  "$(grep -q 'audit-policy-file=/etc/kubernetes/audit-policy.yaml' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((score++))

chk "--audit-log-path=/var/log/kubernetes/audit.log configured" \
  "$(grep -q 'audit-log-path=/var/log/kubernetes/audit.log' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((score++))

chk "--audit-log-maxbackup=2 configured" \
  "$(grep -q 'audit-log-maxbackup=2' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((score++))

chk "Audit log file exists at /var/log/kubernetes/audit.log" \
  "$([ -f /var/log/kubernetes/audit.log ] && echo true || echo false)" && ((score++))

score_line $score $total
