# nix-config

Nix configuration for macOS and NixOS machines.

## Machines

| Name | Type | Description |
|------|------|-------------|
| Liams-MacBook-Pro | Darwin | Personal MacBook |
| trantor | NixOS | Home server |

## Structure

```
nix-config/
├── flake.nix
├── user-config.nix
├── disko/                       # Disk configurations
├── modules/
│   ├── darwin/                  # macOS machines
│   ├── nixos/                   # NixOS machines
│   ├── home/                    # Home-manager
│   ├── users/                   # User definitions
│   └── shared/                  # Cross-platform modules
└── secrets/                     # sops-encrypted secrets
```

## macOS Setup

Install Nix:
```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Clone and build:
```sh
git clone https://github.com/VanderpoelLiam/nix-config.git
cd nix-config
softwareupdate --install-rosetta --agree-to-license
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.Liams-MacBook-Pro.system"
sudo ./result/sw/bin/darwin-rebuild switch --flake .
```
It is normal to have to run this last step multiple times until all dependencies are resolved.

## Trantor Setup

Assumes we have already setup a piKVM `trantor-kvm` and connected it to the `trantor`. See [piKVM cheatsheet](https://docs.pikvm.org/cheatsheet/).

### Boot NixOS via piKVM

We use `netboot` mounted on a piKVM to boot the NixOS installer. Download the [netboot.xyz ISO](https://netboot.xyz/downloads/). Upload and mount the ISO on the KVM, see [piKVM Mass Storage Drive](https://docs.pikvm.org/msd/). Boot from this ISO then select NixOS.

### Install
Based on [Installing on a machine with no operating system](https://github.com/nix-community/nixos-anywhere/blob/main/docs/howtos/no-os.md):

```sh
# On NixOS installer (via trantor-kvm console):
passwd
ip addr

# From Mac:
nix run github:nix-community/nixos-anywhere -- --flake '.#trantor' --target-host nixos@<ip from prev step>

# Reboot, unlock LUKS via trantor-kvm, then:
ssh liam@trantor
```
