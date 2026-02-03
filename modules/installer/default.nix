{ pkgs, ... }:

let
  userConfig = import ../../user-config.nix;
in
{
  imports = [
    "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${pkgs.path}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  # Use beta cache for faster downloads
  # See this discussion: https://discourse.nixos.org/t/anyone-get-really-slow-downloads-from-cache-nixos-org/73941
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://aseipp-nix-cache.global.ssl.fastly.net"
    ];
  };
  
  security.sudo.wheelNeedsPassword = false;

  users.users.${userConfig.global.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ userConfig.global.sshPublicKey ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    rsync
  ];
  system.stateVersion = "25.11";
}
