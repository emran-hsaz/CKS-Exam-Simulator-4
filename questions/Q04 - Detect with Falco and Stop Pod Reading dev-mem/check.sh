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
hdr "Q4 | Detect with Falco and Stop Pod Reading /dev/mem (3 pts)"

# Check Falco rule exists in /etc/falco/rules.d/
rule_exists=$(find /etc/falco/rules.d/ -name "*.yaml" -exec grep -l "dev/mem\|/dev/mem" {} \; 2>/dev/null | wc -l)
chk "Falco rule for /dev/mem exists in /etc/falco/rules.d/" \
  "$([ "$rule_exists" -gt 0 ] && echo true || echo false)" && ((score++))

# Check that 'nvidia' (the offending deployment) is scaled to 0
nvidia_rep=$(kubectl get deploy nvidia -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
chk "Offending Deployment (nvidia) scaled to 0 replicas" \
  "$([ "$nvidia_rep" = "0" ] && echo true || echo false)" && ((score++))

# Check the other two are still running
cpu_ready=$(kubectl get deploy cpu -n default -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
gpu_ready=$(kubectl get deploy gpu -n default -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
chk "Other Deployments (cpu, gpu) are still running" \
  "$([ "${cpu_ready:-0}" -ge 1 ] && [ "${gpu_ready:-0}" -ge 1 ] && echo true || echo false)" && ((score++))

score_line $score $total
