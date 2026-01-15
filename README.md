# nix-config

Nix configuration for macOS and NixOS machines.

## Machines

| Name | Type | Description |
|------|------|-------------|
| Liams-MacBook-Pro | Darwin | Personal MacBook |
| trantor | NixOS | Home server |
| hyperion | NixOS | Home server |

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

## Secrets (sops-nix)

See [sops-nix documentation](https://github.com/Mic92/sops-nix).

### First-time setup

These steps need to be run from our macOS client machine.

Generate age key ([docs](https://github.com/Mic92/sops-nix?tab=readme-ov-file#usage-example)):
```sh
mkdir -p "$HOME/Library/Application Support/sops/age"
nix-shell -p age --run "age-keygen -o '$HOME/Library/Application Support/sops/age/keys.txt'"
```

This outputs our public key (starts with `age1...`). Add it to `.sops.yaml` as the key for `admin_liam`.

### Setup for a new NixOS server

We take the example of setting up secrets for the `hyperion` server, but the procedure is similar for any server.

**Important:** You can encrypt secrets before the target machine exists. Initially, secrets are encrypted only with the client macOs key. After installation, we can add the machine's key.

### Pre-installation steps

Create and encrypt secrets file on the client machine:
```sh
cp secrets/hyperion.yaml.example secrets/hyperion.yaml

# Replace placeholders your actual secret values

# Encrypt the file in-place
nix-shell -p sops --run "sops -e -i secrets/hyperion.yaml"
```

### Post-installation steps

TODO: Double check this is the easiest approach as we need to ssh in initially to the server anyway post-instal and pre-tailscale working, mayb using ssh-to-age is easier, see https://github.com/Mic92/sops-nix?tab=readme-ov-file#usage-example, section 3. Get a public key for your target machine

On the `hyperion` server once NixOS is installed:

Generate age key:
```sh
sudo mkdir -p /var/lib/sops-nix
sudo age-keygen -o /var/lib/sops-nix/key.txt
```

This outputs our public key (starts with `age1...`). Add it to `.sops.yaml` as the key for `server_hyperion`, i.e.: 

```yaml
keys:
    - &admin_liam age1...
    - &server_hyperion age1...  # Add this line with public key from previous step

creation_rules:
    - path_regex: secrets/hyperion\.yaml$
    key_groups:
        - age:
            - *macbook_liam
            - *server_hyperion  # Add this line
```

Re-encrypt secrets to include the machine's key:
```sh
nix-shell -p sops --run "sops updatekeys secrets/hyperion.yaml"
```

Deploy:
```sh
just deploy hyperion
```

### Editing secrets

To edit an already-encrypted secrets file:

```sh
# This opens the decrypted file in vim
nix-shell -p sops --run "EDITOR=vim sops secrets/hyperion.yaml"
```

Make changes, then save the file (:wq), sops will automatically re-encrypt.

<!-- ## Trantor Setup

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
``` -->
