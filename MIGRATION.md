# Migration Tracking

Temporary file - delete when migration complete.

## Docker Compose Services

- [ ] List services from existing docker-compose.yml
- [ ] Determine native NixOS vs container for each

### Native NixOS
Services with NixOS modules.

| Service | Status | Notes |
|---------|--------|-------|
| | | |

### Keep in Docker
Services without NixOS modules - manage via `virtualisation.oci-containers`.

| Service | Status | Notes |
|---------|--------|-------|
| | | |

## Data Directories

- [ ] Document mount points / data paths to preserve

## Post-Migration Cleanup

- [ ] Delete this file
- [ ] Remove any migration-specific code
