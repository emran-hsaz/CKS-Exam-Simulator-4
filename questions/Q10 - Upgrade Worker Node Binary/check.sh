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
hdr "Q10 | Upgrade Worker Node (4 pts)"

# Find worker node (non-control-plane)
WORKER=$(kubectl get nodes --no-headers 2>/dev/null \
  | grep -v 'control-plane\|master' | awk '{print $1}' | head -1)

if [ -z "$WORKER" ]; then
  echo "  Could not determine worker node name."
  score_line $score $total
  exit 0
fi

# Check worker is Ready
worker_status=$(kubectl get node "$WORKER" --no-headers 2>/dev/null | awk '{print $2}')
chk "Worker node $WORKER is Ready" \
  "$([ "$worker_status" = "Ready" ] && echo true || echo false)" && ((score++))

# BUG FIX: grep -qv on a single string always exits 0 because grep -v prints lines NOT matching,
# and the status string itself ('Ready') doesn't contain 'SchedulingDisabled' so grep -v prints
# it, exits 0, -q suppresses output — meaning it ALWAYS passes.
# Fix: use a direct string comparison instead.
chk "Worker node $WORKER is not cordoned (SchedulingDisabled)" \
  "$(echo "$worker_status" | grep -qw 'SchedulingDisabled' && echo false || echo true)" && ((score++))

# Check version matches control plane
cp_ver=$(kubectl get nodes --no-headers 2>/dev/null \
  | grep -E 'control-plane|master' | awk '{print $5}' | head -1)
w_ver=$(kubectl get node "$WORKER" --no-headers 2>/dev/null | awk '{print $5}')
chk "Worker kubelet version matches control plane ($cp_ver)" \
  "$([ -n "$cp_ver" ] && [ -n "$w_ver" ] && [ "$cp_ver" = "$w_ver" ] && echo true || echo false)" && ((score++))

# Check all nodes Ready — count any non-Ready status
not_ready=$(kubectl get nodes --no-headers 2>/dev/null \
  | awk '{print $2}' | grep -v '^Ready$' | wc -l)
chk "All cluster nodes are Ready" \
  "$([ "$not_ready" = "0" ] && echo true || echo false)" && ((score++))

score_line $score $total
