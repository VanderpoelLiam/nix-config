#!/usr/bin/env -S just --justfile

default:
  @just --list

check:
    nix flake check

update:
    nix flake update

check-darwin:
    nix build .#darwinConfigurations."Liams-MacBook-Pro".system --dry-run

check-nixos machine:
    nix build .#nixosConfigurations.{{machine}}.config.system.build.toplevel --dry-run

deploy $host: (copy host)
	nixos-rebuild-ng switch --flake .#{{host}} --target-host {{host}} --build-host {{host}} --no-reexec --sudo

copy $host:
	rsync -ax --delete --rsync-path="sudo rsync" ./ {{host}}:/etc/nixos/

gc:
    nix-collect-garbage --delete-older-than 10d
