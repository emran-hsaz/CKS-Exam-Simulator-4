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
hdr "Q16 | Secure API Server Authentication and Authorization (4 pts)"

# BUG FIX: grep -q 'anonymous-auth=false' would also match '--anonymous-auth=false-something'
# Use grep with exact flag boundary using a more precise pattern
anon_val=$(grep 'anonymous-auth' "$APISERVER" 2>/dev/null \
  | grep -oP 'anonymous-auth=\K[^ "]+' | tr -d '"' | head -1)
chk "--anonymous-auth=false" \
  "$([ "$anon_val" = "false" ] && echo true || echo false)" && ((score++))

# BUG FIX: previous grep for 'Node,RBAC|RBAC,Node' missed trailing spaces/quotes.
# Extract the authorization-mode value precisely and check both Node and RBAC are present.
auth_val=$(grep 'authorization-mode' "$APISERVER" 2>/dev/null \
  | grep -oP 'authorization-mode=\K[^ "]+' | tr -d '"' | head -1)
has_node=$(echo "$auth_val" | grep -q 'Node' && echo true || echo false)
has_rbac=$(echo "$auth_val" | grep -q 'RBAC' && echo true || echo false)
chk "--authorization-mode contains Node and RBAC (current: ${auth_val:-not set})" \
  "$([ "$has_node" = "true" ] && [ "$has_rbac" = "true" ] && echo true || echo false)" && ((score++))

# Check NodeRestriction is in admission plugins
chk "NodeRestriction in --enable-admission-plugins" \
  "$(grep 'enable-admission-plugins' "$APISERVER" 2>/dev/null \
     | grep -q 'NodeRestriction' && echo true || echo false)" && ((score++))

# Check API server pod is running
api_running=$(kubectl get pod -n kube-system -l component=kube-apiserver \
  --no-headers 2>/dev/null | grep -c Running)
chk "API server is Running after changes" \
  "$([ "$api_running" -ge 1 ] && echo true || echo false)" && ((score++))

score_line $score $total
