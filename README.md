# nix-config

Nix configuration for macOS and NixOS machines.

## Machines

| Name | Type | Description |
|------|------|-------------|
| Liams-MacBook-Pro | Darwin | Personal MacBook |
| hyperion | NixOS | Home server |

## Structure

```
nix-config/
├── flake.nix
├── user-config.nix
├── modules/
│   ├── darwin/
│   │   └── Liams-MacBook-Pro/
│   ├── nixos/
│   │   └── hyperion/
│   ├── installer/
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

Add the age public key to `.sops.yaml` as `admin_liam`.

### Secrets First-time setup 

**Only perform these steps when creating the server's secrets file `secrets/<server>.yaml` for the first time. Run all commands on the MacOS client machine.**

We use [sops-nix](https://github.com/Mic92/sops-nix) for secret management. Initially, secrets are encrypted only with the Mac's age key. After a server is setup for the first time, we add the server's age key to `.sops.yaml` so the server can then decrypt and use the secrets.

Create the secrets file:
```sh
touch secrets/<server>.yaml
```

Add your secrets, for example:
```yaml
cloudflare_api_token: your-cloudflare-api-token
pihole_password: your-pihole-admin-password
```

Encrypt the file in-place:
```sh
nix-shell -p sops --run "sops -e -i secrets/<server>.yaml"
```

Secrets can be viewed and edited with:
```sh
nix-shell -p sops --run "EDITOR=vim sops secrets/<server>.yaml"
```

## NixOS Server Setup

TODO: IN PROGRESS
<!-- Build the installer ISO (does not work on Mac):
```sh
just build-iso
```

Flash to USB:
```sh
# Find USB, e.g. if the usb is /dev/disk4 then replace diskN with disk4 below
diskutil list                                    
diskutil unmountDisk /dev/diskN
sudo dd if=install-iso of=/dev/rdiskN bs=4M status=progress
diskutil eject /dev/diskN
```

Boot server from USB and get the ip address of the server:
```sh
ip addr # Note IP address after inet (e.g 192.168.1.87)
```

SSH in:
```sh
ssh liam@<ip-address>
```

Partition, install, set password, and reboot:
```sh
sudo nix run github:nix-community/disko -- --mode destroy,format,mount --flake github:VanderpoelLiam/nix-config#hyperion
sudo nixos-install --flake github:VanderpoelLiam/nix-config#hyperion --no-root-password
nixos-enter --root /mnt
passwd liam
exit
sudo reboot
```

SSH into the installed system and configure Tailscale with a [single-use auth key](https://login.tailscale.com/admin/settings/keys):
```sh
ssh liam@<ip-address>
sudo tailscale up --advertise-exit-node --auth-key=<auth-key>
```

Get the server's age key and add it to `.sops.yaml`:
```sh
nix-shell -p ssh-to-age --run "ssh-keyscan hyperion | ssh-to-age"
```

Re-encrypt secrets and deploy:
```sh
nix-shell -p sops --run "sops updatekeys modules/nixos/hyperion/secrets.yaml"
just deploy hyperion
``` -->
