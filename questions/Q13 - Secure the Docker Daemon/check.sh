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
hdr "Q13 | Secure the Docker Daemon (3 pts)"

# BUG FIX: "! id testuser | grep -q docker" is a bash precedence bug.
# The ! only negates the exit code of 'id', not the pipe.
# So this reads as: (!id testuser) | grep -q docker
# which pipes the output of id (regardless of negation) to grep.
# Fix: capture the group list first, then test it.
user_groups=$(id testuser 2>/dev/null)
chk "testuser is NOT in the docker group" \
  "$(echo "$user_groups" | grep -qw 'docker' && echo false || echo true)" && ((score++))

# Check socket owner
sock_owner=$(stat -c '%U' /var/run/docker.sock 2>/dev/null)
chk "Docker socket owner = root" \
  "$([ "$sock_owner" = "root" ] && echo true || echo false)" && ((score++))

# Check socket group is not testuser
sock_group=$(stat -c '%G' /var/run/docker.sock 2>/dev/null)
chk "Docker socket group is not owned by testuser" \
  "$([ "$sock_group" != "testuser" ] && echo true || echo false)" && ((score++))

score_line $score $total
