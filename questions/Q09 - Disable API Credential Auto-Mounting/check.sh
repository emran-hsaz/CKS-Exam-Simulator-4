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
hdr "Q9 | Disable API Credential Auto-Mounting (4 pts)"

# Check SA automount is false
auto=$(kubectl get sa app-sa -n default -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null)
chk "ServiceAccount app-sa automountServiceAccountToken = false" \
  "$([ "$auto" = "false" ] && echo true || echo false)" && ((score++))

# BUG FIX: search ALL volumes for any projected volume — not just index [0]
# The projected volume may not be the first volume in the list
proj_count=$(kubectl get deploy token-app -n default \
  -o jsonpath='{.spec.template.spec.volumes[*].projected}' 2>/dev/null | \
  python3 -c "
import sys, json
data = sys.stdin.read().strip()
# jsonpath returns space-separated JSON objects when multiple volumes exist
# Try parsing as single object first, then check for 'sources' key
try:
    obj = json.loads(data)
    print('true' if obj else 'false')
except:
    print('true' if data and data != 'null' else 'false')
" 2>/dev/null)
chk "Deployment has a projected volume" \
  "$([ "$proj_count" = "true" ] && echo true || echo false)" && ((score++))

# BUG FIX: search ALL volumeMounts for the target path — not just index [0]
# The SA mount may not be the first volumeMount
target_mount="/var/run/secrets/kubernetes.io/serviceaccount"
all_mounts=$(kubectl get deploy token-app -n default \
  -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[*].mountPath}' 2>/dev/null)
chk "Token mounted at /var/run/secrets/kubernetes.io/serviceaccount" \
  "$(echo "$all_mounts" | tr ' ' '\n' | grep -qx "$target_mount" && echo true || echo false)" && ((score++))

# Check deployment still running
avail=$(kubectl get deploy token-app -n default -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
chk "Deployment token-app is still running" \
  "$([ -n "$avail" ] && [ "$avail" -gt 0 ] 2>/dev/null && echo true || echo false)" && ((score++))

score_line $score $total
