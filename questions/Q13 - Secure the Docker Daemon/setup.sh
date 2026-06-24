#!/bin/bash
echo "Setting up Q13 — insecure Docker permissions..."

# Create testuser if it doesn't exist
id testuser &>/dev/null || useradd -m testuser

# Add testuser to docker group (creating it if needed)
groupadd docker 2>/dev/null || true
usermod -aG docker testuser

# Make socket owned by testuser (simulate insecure setup)
touch /var/run/docker.sock 2>/dev/null || true
chown testuser:testuser /var/run/docker.sock 2>/dev/null || true

echo ""
echo "Done."
echo "  testuser is in the docker group: $(groups testuser)"
echo "  /var/run/docker.sock owner: $(stat -c '%U:%G' /var/run/docker.sock 2>/dev/null)"
echo ""
echo "Remove testuser from docker group and fix socket ownership."
