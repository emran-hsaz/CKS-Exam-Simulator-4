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

score=0; total=3
hdr "Q11 | SPDX Document and Remove Vulnerable Container (3 pts)"

# --- Check 1: alpine:3.19.1 container removed ---
# Get all images as exact newline-separated entries, check none exactly matches alpine:3.19.1
all_images=$(kubectl get deploy multi-alpine -n default \
  -o jsonpath='{.spec.template.spec.containers[*].image}' 2>/dev/null | tr ' ' '\n')

chk "Container alpine:3.19.1 has been removed from Deployment" \
  "$(echo "$all_images" | grep -qx 'alpine:3.19.1' && echo false || echo true)" && ((score++))

# --- Check 2: Deployment now has exactly 2 containers ---
count=$(kubectl get deploy multi-alpine -n default \
  -o go-template='{{len .spec.template.spec.containers}}' 2>/dev/null)

chk "Deployment now has 2 containers (was 3)" \
  "$([ "$count" = "2" ] && echo true || echo false)" && ((score++))

# --- Check 3: SPDX file exists and is non-empty ---
chk "SPDX file /root/alpine.spdx exists and is non-empty" \
  "$([ -s /root/alpine.spdx ] && echo true || echo false)" && ((score++))

score_line $score $total

# Show current state for debugging
echo -e "  ${CYAN}Current images in Deployment:${NC}"
echo "$all_images" | while read -r img; do echo "    - $img"; done
echo -e "  ${CYAN}Container count:${NC} ${count:-unknown}"
[ -f /root/alpine.spdx ] && \
  echo -e "  ${CYAN}SPDX file size:${NC} $(du -h /root/alpine.spdx | cut -f1)" || \
  echo -e "  ${CYAN}SPDX file:${NC} not found"
