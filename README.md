# My Nix Configuration for macOS

Minimal instructions to install and configure nix-darwin.

## Installation

Install Nix using the Determinate Systems installer:

```shell
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

See the [Determinate Nix Installer documentation](https://github.com/DeterminateSystems/nix-installer) for more details.

## Setup

Clone this repository to your home directory:

```shell
git clone https://github.com/VanderpoelLiam/nix-config.git
cd nix-config
```

Install Rosetta 2 (required for Intel Homebrew prefix):

```shell
softwareupdate --install-rosetta --agree-to-license
```

Create `user-config.nix` with your machine-specific information:

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

Build the nix-darwin system configuration:

```shell
nix --extra-experimental-features 'nix-command flakes'  build ".#darwinConfigurations.{{hostname}}.system"
```

Replacing `{{hostname}}` with the hostname of the machine.

Switch to the configuration:

```shell
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#"
```

You may need to run step 2 multiple times until all dependencies are resolved.

## Updating

After initial setup, you can use the convenience aliases:

- `nixswitch` - Rebuild and switch to the current configuration
- `nixup` - Update flake inputs and rebuild

## Configuration Structure

```shell
hosts
`-- darwin
    |-- apps
    |   |-- [...]           
    |   `-- default.nix
    |-- default.nix
    |-- environment.nix
    |-- home.nix
    |-- homebrew.nix
    `-- system.nix
home-manager
|-- apps
|   |-- [...]        
|   `-- default.nix
|-- default.nix
`-- home.nix
```

### Directory Overview

- **`hosts/darwin/`** - macOS-specific system config and modules
- **`home-manager/`** - Cross-platform reusable modules

### Adding New Configuration

#### Packages
- **General packages**: Add to `home-manager/home.nix`
- **macOS-specific packages**: Add to `hosts/darwin/home.nix`

#### Apps

Apps follow the same structure in both `home-manager/apps/` and `hosts/darwin/apps/`:

| Config Files | Structure |
|-------------|-----------|
| None | `apps/newapp.nix` |
| Single | `apps/newapp/`<br>`├── newapp.nix`<br>`└── config.json` |
| Multiple | `apps/newapp/`<br>`├── newapp.nix`<br>`└── config/`   |
