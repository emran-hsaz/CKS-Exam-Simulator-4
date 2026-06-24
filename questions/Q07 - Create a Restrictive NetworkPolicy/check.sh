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

score=0; total=4
hdr "Q7 | Create a Restrictive NetworkPolicy (4 pts)"

np_count=$(kubectl get networkpolicy -n secure-ns --no-headers 2>/dev/null | wc -l)
chk "At least one NetworkPolicy exists in namespace secure-ns" \
  "$([ "$np_count" -ge 1 ] && echo true || echo false)" && ((score++))

ptypes=$(kubectl get networkpolicy -n secure-ns -o jsonpath='{.items[*].spec.policyTypes[*]}' 2>/dev/null)
chk "policyTypes includes Ingress (deny-all default)" \
  "$(echo "$ptypes" | grep -q Ingress && echo true || echo false)" && ((score++))

nssel=$(kubectl get networkpolicy -n secure-ns -o jsonpath='{.items[*].spec.ingress[*].from[*].namespaceSelector}' 2>/dev/null)
chk "Ingress rule uses namespaceSelector" \
  "$([ -n "$nssel" ] && echo true || echo false)" && ((score++))

label_val=$(kubectl get networkpolicy -n secure-ns -o jsonpath='{.items[*].spec.ingress[*].from[*].namespaceSelector.matchLabels.access}' 2>/dev/null)
chk "namespaceSelector references access=granted label" \
  "$([ "$label_val" = "granted" ] && echo true || echo false)" && ((score++))

score_line $score $total
