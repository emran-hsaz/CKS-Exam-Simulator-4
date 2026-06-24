#!/bin/bash
MARKS=5
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

score=0; total=5
hdr "Q12 | Fix Deployment for Restricted PSS (5 pts)"

ape=$(kget deploy/pss-app restricted-ns '.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation')
chk "allowPrivilegeEscalation = false" "$([ "$ape" = "false" ] && echo true || echo false)" && ((score++))

rnn=$(kget deploy/pss-app restricted-ns '.spec.template.spec.containers[0].securityContext.runAsNonRoot')
chk "runAsNonRoot = true" "$([ "$rnn" = "true" ] && echo true || echo false)" && ((score++))

caps=$(kget deploy/pss-app restricted-ns '.spec.template.spec.containers[0].securityContext.capabilities.drop[*]')
chk "capabilities.drop includes ALL" \
  "$(echo "$caps" | grep -q "ALL" && echo true || echo false)" && ((score++))

seccomp=$(kget deploy/pss-app restricted-ns '.spec.template.spec.containers[0].securityContext.seccompProfile.type')
[ -z "$seccomp" ] && seccomp=$(kget deploy/pss-app restricted-ns '.spec.template.spec.securityContext.seccompProfile.type')
chk "seccompProfile.type = RuntimeDefault or Localhost" \
  "$([ "$seccomp" = "RuntimeDefault" ] || [ "$seccomp" = "Localhost" ] && echo true || echo false)" && ((score++))

avail=$(kubectl get deploy pss-app -n restricted-ns -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
chk "Deployment pss-app Pods are Running" \
  "$([ -n "$avail" ] && [ "$avail" -gt 0 ] 2>/dev/null && echo true || echo false)" && ((score++))

score_line $score $total
