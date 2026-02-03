{ pkgs, lib, ... }:

let
  userConfig = import ../../user-config.nix;
in
{
  imports = [
    "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${pkgs.path}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use beta cache for faster downloads
  # See this discussion: https://discourse.nixos.org/t/anyone-get-really-slow-downloads-from-cache-nixos-org/73941
  nix.settings = {
    substituters = [
      "https://aseipp-nix-cache.global.ssl.fastly.net"
    ];
  };

  # Locale
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = userConfig.global.timezone;

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Create user with SSH key
  users.users.${userConfig.global.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ userConfig.global.sshPublicKey ];
  };

  programs.zsh.enable = true;

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Essential packages for installation
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    rsync
  ];

  system.stateVersion = "25.11";
}
