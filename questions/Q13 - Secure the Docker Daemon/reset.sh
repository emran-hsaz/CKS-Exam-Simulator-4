#!/bin/bash
usermod -aG docker testuser 2>/dev/null || true
chown testuser:testuser /var/run/docker.sock 2>/dev/null || true
echo "Q13 reset done. testuser re-added to docker group and socket ownership restored."
