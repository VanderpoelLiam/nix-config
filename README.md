# nix-config

Nix configuration for macOS and NixOS machines.

## Machines

| Name | Type | Description |
|------|------|-------------|
| Liams-MacBook-Pro | Darwin | Personal MacBook |
| hyperion | NixOS | Home server |
| trantor | NixOS | Media server |

## Structure

```
nix-config/
├── flake.nix
├── user-config.nix
├── modules/
│   ├── darwin/
│   │   └── Liams-MacBook-Pro/
│   ├── nixos/
│   │   ├── hyperion/
│   │   └── trantor/
│   ├── services/
│   ├── users/
│   └── shared/
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

Generate an SSH key:
```sh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

Add the public key to `user-config.nix` as `sshPublicKey`:
```sh
cat ~/.ssh/id_ed25519.pub
```

Convert your SSH key to age format for secrets management:
```sh
mkdir -p "$HOME/Library/Application Support/sops/age"
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519" > "$HOME/Library/Application Support/sops/age/keys.txt"
nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"
```

Add the age public key to `.sops.yaml` as `admin_liam`:
```yaml
keys:
  - &admin_liam age1...

creation_rules:
  - path_regex: modules/nixos/<server>/secrets\.yaml$
    key_groups:
      - age:
          - *admin_liam
[...]
```

### Secrets first-time setup 

**Only perform these steps when creating the server's secrets file `modules/nixos/<server>/secrets.yaml` for the first time. Run all commands on the MacOS client machine.**

We use [sops-nix](https://github.com/Mic92/sops-nix) for secret management. Initially, secrets are encrypted only with the Mac's age key. After a server is setup for the first time, we add the server's age key to `.sops.yaml` so the server can then decrypt and use the secrets.

Create the secrets file:
```sh
touch modules/nixos/<server>/secrets.yaml
```

Add your secrets, for example:
```yaml
cloudflare_api_token: your-cloudflare-api-token
pihole_password: your-pihole-admin-password
```

Encrypt the file in-place:
```sh
nix-shell -p sops --run "sops -e -i modules/nixos/<server>/secrets.yaml"
```

Secrets can be viewed and edited with:
```sh
nix-shell -p sops --run "EDITOR=vim sops modules/nixos/<server>/secrets.yaml"
```

## NixOS Server Setup

The first step is to create a bootable USB drive running NixOS.

### Create a bootable USB

Create a [bootable USB for netboot.xyz](https://netboot.xyz/docs/booting/usb/) and boot from NixOS. Or if that doesnt work, directly flash [NixOS Minimal ISO image](https://nixos.org/download/#nixos-iso) to a USB. Then boot from the USB and run:

```sh
passwd  # Set a temporary password to ssh in for the install
ip addr # Note IP address after inet (e.g 192.168.1.87)
```

SSH in from Mac:
```sh
ssh nixos@<ip-address>
```

### Install the flake

Partition, install, set password, and reboot:
```sh
sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode destroy,format,mount --flake github:VanderpoelLiam/nix-config#<server>
sudo nixos-install --flake github:VanderpoelLiam/nix-config#<server> --no-root-password
sudo reboot
```

SSH into the installed system and configure Tailscale:
```sh
ssh-keygen -R <ip-address> # Remove the stale host key from the ISO boot
ssh liam@<ip-address>
sudo tailscale up --advertise-exit-node 
```

I reccomend disabling key expiry in the Tailscale Admin console, and edit the ACL tags to tag the machine as a `server`. My ACL rules are setup such that I can only ssh into machines tagged as a server. I also setup [Tailscale SSH](https://tailscale.com/docs/features/tailscale-ssh) to access my servers from a web browser if I do not have access to my Macbook:

```sh
sudo tailscale set --ssh
```



### Add Server Key to sops

If the server uses secrets, Add the server's SSH host key to sops. This uses [ssh-to-age](https://github.com/Mic92/ssh-to-age) to convert the existing SSH host key 
(no need to generate a separate age key).

From Mac:
```sh
nix-shell -p ssh-to-age --run "ssh-keyscan <server> | ssh-to-age"
```

Add the output (starts with `age1...`) to `.sops.yaml`:
```yaml
keys:
    - &admin_liam age1...            # Your Mac's key
    - &server_<server> age1...       # Add server key here

creation_rules:
    - path_regex: secrets/<server>\.yaml$
      key_groups:
          - age:
              - *admin_liam
              - *server_<server>
```

Re-encrypt secrets and deploy:
```sh
nix-shell -p sops --run "sops updatekeys secrets/<server>.yaml"
just deploy <server>
```