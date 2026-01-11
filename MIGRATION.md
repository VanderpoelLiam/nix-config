# Migration Tracking

Temporary file - delete when migration complete.

## Completed

- [x] Restructured nix-config for multi-machine support
- [x] Created `modules/nixos/trantor/` base config
- [x] Set up disko for LUKS + ext4 disk encryption
- [x] Configured Tailscale-only SSH (no regular SSH)
- [x] Added `justfile` for common commands

## Remaining Tasks

### Phase 4: Services
Add services to `modules/nixos/trantor/services/`:
```sh
just check-nixos trantor  # validate after each
```

### Phase 5: Secrets
- [ ] Set up sops-nix
- [ ] Move `gitEmail` from `user-config.nix` to secrets
- [ ] Add Tailscale auth key to secrets

## Docker Compose Services

- [ ] List services from existing docker-compose.yml
- [ ] Determine native NixOS vs container for each

### Native NixOS
Services with NixOS modules - add to `modules/nixos/trantor/services/`.

| Service | Status | Notes |
|---------|--------|-------|
| Tailscale | done | `services/tailscale.nix` |
| | | |

### Keep in Docker
Services without NixOS modules - manage via `virtualisation.oci-containers`.

| Service | Status | Notes |
|---------|--------|-------|
| | | |

## Data Directories

- [ ] Document mount points / data paths to preserve

## Installation Checklist

When ready to deploy:
1. Set up piKVM (`trantor-kvm`)
2. Boot NixOS via netboot.xyz
3. Run `nix run github:nix-community/nixos-anywhere -- --flake '.#trantor' --target-host nixos@<IP>`
4. Unlock LUKS via piKVM on reboot
5. Run `tailscale up` on server

## Post-Migration Cleanup

- [ ] Delete this file
- [ ] Remove any migration-specific code
