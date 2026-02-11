#!/usr/bin/env -S just --justfile

default:
  @just --list

check:
    nix flake check

update:
    nix flake update

deploy $host:
	ssh {{host}} "sudo nixos-rebuild switch --refresh --flake github:VanderpoelLiam/nix-config#{{host}}"

gc:
    nix-collect-garbage --delete-older-than 10d
