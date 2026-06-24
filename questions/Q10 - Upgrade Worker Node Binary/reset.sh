#!/bin/bash
echo "Q10 — Node upgrade reset."
echo "To reset: manually uncordon the node if needed."
WORKER=$(kubectl get nodes --no-headers 2>/dev/null | grep -v 'control-plane\|master' | awk '{print $1}' | head -1)
[ -n "$WORKER" ] && kubectl uncordon "$WORKER" --ignore-not-found 2>/dev/null || true
echo "Q10 reset done."
