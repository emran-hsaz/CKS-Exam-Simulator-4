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
hdr "Q3 | Dockerfile and Deployment Security (4 pts)"

# Check Dockerfile has USER nobody
chk "Dockerfile contains USER nobody" \
  "$(grep -q 'USER nobody' /root/Dockerfile 2>/dev/null && echo true || echo false)" && ((score++))

# Check runAsUser = 65535
rau=$(kget deploy/secure-app default '.spec.template.spec.containers[0].securityContext.runAsUser')
chk "Deployment runAsUser = 65535" "$([ "$rau" = "65535" ] && echo true || echo false)" && ((score++))

# Check readOnlyRootFilesystem = true
rfs=$(kget deploy/secure-app default '.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem')
chk "Deployment readOnlyRootFilesystem = true" "$([ "$rfs" = "true" ] && echo true || echo false)" && ((score++))

# BUG FIX: privileged must be explicitly set to false — absent field is NOT the same as false
# An absent field means the runtime default (which may be true in some cases)
priv=$(kget deploy/secure-app default '.spec.template.spec.containers[0].securityContext.privileged')
chk "Deployment privileged = false (must be explicitly set)" \
  "$([ "$priv" = "false" ] && echo true || echo false)" && ((score++))

score_line $score $total
