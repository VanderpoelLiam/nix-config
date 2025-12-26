{ inputs, outputs, config, lib, hostname, system, username, pkgs, ... }:
{
  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [bash zsh];
    systemPackages = with pkgs; [
      coreutils
    ];
    systemPath = ["/opt/homebrew/bin"];
    pathsToLink = ["/Applications"];
  };

  # Let Determinate Nix handle Nix configuration
  nix.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
}

