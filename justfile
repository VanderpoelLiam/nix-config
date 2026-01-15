#!/usr/bin/env -S just --justfile

# Default recipe - show available commands
default:
  @just --list

# Check flake
check:
    nix flake check

# Dry-run build for my MacBook
check-darwin:
    nix build .#darwinConfigurations."Liams-MacBook-Pro".system --dry-run

# Dry-run build for NixOS machine
check-nixos machine:
    nix build .#nixosConfigurations.{{machine}}.config.system.build.toplevel --dry-run

# Build and switch my MacBook
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
