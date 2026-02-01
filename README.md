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

Generate an SSH key:
```sh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

Add the public key to `user-config.nix` as `sshPublicKey`:
```sh
cat ~/.ssh/id_ed25519.pub
```

Convert your SSH key to age format for secrets management ([docs](https://github.com/Mic92/ssh-to-age)):
```sh
mkdir -p "$HOME/Library/Application Support/sops/age"
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519" > "$HOME/Library/Application Support/sops/age/keys.txt"
```

Get the age public key and add it to `.sops.yaml` as the key for `admin_liam`:
```sh
nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"
```

### Secrets management for servers

We use [sops-nix](https://github.com/Mic92/sops-nix) for secret management. **Important: You can and should encrypt secrets before the target machine exists.** Initially, secrets are encrypted only with the Mac's age key. After a server is setup for the first time, we add the server's age key to `.sops.yaml` so the server can then decrypt and use the secrets. 

#### First-time setup

**Only perform these steps when creating the server's secrets file `secrets/<server>.yaml` for the first time. Run all commands on the MacOS client machine.**

Create the secrets file:
```sh
touch secrets/<server>.yaml
```

Add your secrets, for example:
```yaml
# Example secrets file 
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

Save and exit vim (`!wq`) to save any changes.

## NixOS Setup

General steps for installing NixOS on a new server using [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).

### Boot the NixOS Installer

Download the [Minimal Nix ISO image](https://nixos.org/download/#nixos-iso) and flash it to a USB by following the [Creating bootable USB flash drive from a Terminal on macOS instructions](https://nixos.org/manual/nixos/stable/#sec-booting-from-usb-macos). Plug it into the server and boot from the USB, then select: `NixOS Installer LTS`.

### Install

On the server booted into the NixOS installer set the root password:
```sh
sudo su
passwd                # Set password for SSH access during installation
ip addr               # Note IP address after inet (e.g 192.168.1.87)
```

SSH into the server:
```sh
ssh root@<ip-address>
```
Enable flakes:
```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

If accessing `cache.nixos.org` is slow, enable the beta binary cache (see [this discussion](https://discourse.nixos.org/t/anyone-get-really-slow-downloads-from-cache-nixos-org/73941)):
```sh
echo "substituters = https://aseipp-nix-cache.global.ssl.fastly.net" >> ~/.config/nix/nix.conf
```

On any client machine, navigate to the `nix-config` directory then run:
```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake '.#<server>' \
  --target-host root@<ip-address>
```

### Post-Install Setup

After installation, remove the old known host for the ip address from `~/.ssh/known_hosts`. Then ssh into the server::
```sh
ssh liam@<ip-address>
```

TODO: EVERYTHING WORKS UNTIL HERE

Generate a single use Tailscale auth-key, then start Tailscale on the server::
```sh
sudo tailscale up --advertise-exit-node --auth-key=<tailscale-auth-key>
```
After authenticating Tailscale, you can access the server via `ssh liam@<server>`.

### Add Server Key to sops

Add the server's SSH host key to sops. This uses [ssh-to-age](https://github.com/Mic92/ssh-to-age) to convert the existing SSH host key (no need to generate a separate age key).

From Mac:
```sh
nix-shell -p ssh-to-age --run "ssh-keyscan <server> | ssh-to-age"
```

Add the output (starts with `age1...`) to `.sops.yaml`:
```yaml
keys:
    - &admin_liam age1...          # Your Mac's key
    - &server_<name> age1...       # Add server key here

creation_rules:
    - path_regex: secrets/<server>\.yaml$
      key_groups:
          - age:
              - *admin_liam
              - *server_<name>
```

Re-encrypt secrets and deploy:
```sh
nix-shell -p sops --run "sops updatekeys secrets/<server>.yaml"
just deploy <server>
```

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

<!-- ## Hyperion Setup

Follow the [NixOS Setup](#nixos-setup) steps above with `hyperion` as the server name.

### Prerequisites

1. Ensure secrets are encrypted (see [Secrets](#secrets-sops-nix) section)
2. Stop containers on ganymede (can restart if hyperion setup fails):
   ```sh
   ssh ganymede
   docker compose down  # or however containers are managed
   ```

### Verification

```sh
# Check services are running
systemctl status caddy jellyfin sonarr radarr prowlarr jellyseerr qbittorrent
systemctl status podman-pihole podman-homeassistant podman-koifit

# Check logs if issues
journalctl -u caddy -f
journalctl -u podman-pihole -f

# Test ACME certificate
curl -I https://jellyfin.internal.vanderpoel.ch

# Test Pi-hole DNS
dig @localhost example.com
```

### Data Migration

After verifying services are running, migrate data from ganymede:

```sh
# Example: Pi-hole
rsync -av root@ganymede:/var/lib/pihole/ /var/lib/pihole/

# Example: Home Assistant
rsync -av root@ganymede:/var/lib/homeassistant/ /var/lib/homeassistant/

# Restart services after data migration
sudo systemctl restart podman-pihole podman-homeassistant
```

### Rollback

If hyperion fails, restart containers on ganymede:
```sh
ssh ganymede
docker compose up -d  # or however containers are managed
``` -->
