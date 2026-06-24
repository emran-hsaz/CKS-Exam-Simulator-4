# Secure the Docker Daemon

## Task
A node has insecure Docker permissions.

## Requirements

1. Remove the user `testuser` from the `docker` group

2. Ensure that the Docker socket `/var/run/docker.sock` is owned by `root:root`

## Verify

```bash
groups testuser
stat -c '%U:%G' /var/run/docker.sock
```

Verify that `testuser` is no longer part of the docker group and that the Docker socket ownership is correct.
