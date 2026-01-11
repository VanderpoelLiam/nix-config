# Nix configuration tasks

# Check flake
check:
    nix flake check

# Dry-run build for Darwin machine
check-darwin machine:
    nix build .#darwinConfigurations.{{machine}}.system --dry-run

# Dry-run build for NixOS machine
check-nixos machine:
    nix build .#nixosConfigurations.{{machine}}.config.system.build.toplevel --dry-run

# Build and switch Darwin config
switch:
    sudo darwin-rebuild switch --flake .

# Deploy to NixOS machine
deploy machine:
    nixos-rebuild switch --flake .#{{machine}} --target-host liam@{{machine}} --use-remote-sudo

# Update flake inputs
update:
    nix flake update

# Garbage collect old generations
gc:
    nix-collect-garbage --delete-older-than 10d
