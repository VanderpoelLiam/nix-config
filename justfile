#!/usr/bin/env -S just --justfile

default:
  @just --list

check:
    nix flake check

update:
    nix flake update

deploy $host:
	ssh {{host}} "sudo nixos-rebuild switch --refresh --flake github:VanderpoelLiam/nix-config#{{host}}"

build-iso $host:
    ssh {{host}} "rm -rf /tmp/nix-config && git clone https://github.com/VanderpoelLiam/nix-config.git /tmp/nix-config"
    scp {{host}}:$(ssh {{host}} "cd /tmp/nix-config && nix-shell -p nixos-generators --run 'nixos-generate -c modules/installer/default.nix -f install-iso -I nixpkgs=channel:nixos-25.11'") ~/Downloads/

gc:
    nix-collect-garbage --delete-older-than 10d
