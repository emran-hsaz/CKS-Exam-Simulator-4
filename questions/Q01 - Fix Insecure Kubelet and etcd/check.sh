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
hdr "Q1 | Fix Insecure Kubelet and etcd (4 pts)"

KUBELET_CONFIG="/var/lib/kubelet/config.yaml"

anon=$(python3 -c "import yaml; c=yaml.safe_load(open('$KUBELET_CONFIG')); print(c.get('authentication',{}).get('anonymous',{}).get('enabled','not-set'))" 2>/dev/null)
chk "Kubelet anonymous.enabled = false" "$([ "$anon" = "False" ] || [ "$anon" = "false" ] && echo true || echo false)" && ((score++))

mode=$(python3 -c "import yaml; c=yaml.safe_load(open('$KUBELET_CONFIG')); print(c.get('authorization',{}).get('mode','not-set'))" 2>/dev/null)
chk "Kubelet authorization.mode = Webhook" "$([ "$mode" = "Webhook" ] && echo true || echo false)" && ((score++))

chk "Kubelet service is active" "$(systemctl is-active kubelet 2>/dev/null | grep -q active && echo true || echo false)" && ((score++))

ETCD="/etc/kubernetes/manifests/etcd.yaml"
etcd_auth=$(grep -o 'client-cert-auth=[a-z]*' "$ETCD" 2>/dev/null | cut -d= -f2)
chk "etcd --client-cert-auth=true" "$([ "$etcd_auth" = "true" ] && echo true || echo false)" && ((score++))

score_line $score $total
