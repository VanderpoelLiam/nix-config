# My Nix Configuration for macOS

Minimal instructions to install and configure nix-darwin on a fresh Mac to deterministically manage packages and system configuration.

## Installation

Install Nix using the Determinate Systems installer:

```shell
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

See the [Determinate Nix Installer documentation](https://github.com/DeterminateSystems/nix-installer) for more details.

## Setup

1. Clone this repository:

```shell
git clone https://github.com/VanderpoelLiam/nix-config.git
cd nix-config
```

2. Create `user-config.nix` with your machine-specific information:

```nix
{
  # The hostname of the machine
  hostname = "your-hostname";
  
  # The system username
  username = "your-username";
  
  # Git user name and email
  gitName = "Your Name";
  gitEmail = "your.email@example.com";
}
```

## Build and Apply

1. Build the nix-darwin system configuration:

```shell
nix --extra-experimental-features 'nix-command flakes'  build ".#darwinConfigurations.{{hostname}}.system"
```

Replacing `{{hostname}}` with the hostname of the machine.

2. Switch to the configuration:

```shell
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#"
```

You may need to run step 2 multiple times until all dependencies are resolved.

## Updating

After initial setup, you can use the convenience aliases:

- `nixswitch` - Rebuild and switch to the current configuration
- `nixup` - Update flake inputs and rebuild
