{ inputs, outputs, config, lib, hostname, system, username, pkgs, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [bash zsh];
    systemPackages = with pkgs; [
      coreutils
      git
    ];
    systemPath = ["/opt/homebrew/bin"];
    pathsToLink = ["/Applications"];
  };

  # Necessary for using flakes on this system.
  # Determinate Systems manages Nix, so disable nix-darwin's Nix daemon management
  # Nix still works - this just prevents nix-darwin from trying to manage the daemon
  nix.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = hostname;

  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    primaryUser = username;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      dock = {
        autohide = true;
	show-recents = false; # Disable "Recently Used Apps" section
        persistent-apps = [
          "/Applications/Firefox.app"
          "/Applications/Cursor.app"
          "/Applications/WhatsApp.app"
          "/System/Applications/Messages.app"
          "/Applications/Home Assistant.app"
          "/Applications/Bitwarden.app"
          "/Applications/Ghostty.app"
        ];
      };
      NSGlobalDomain = {
	ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 1;
      };
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Google Sans Code is installed via Homebrew cask (see casks below)
  # fonts.packages = [];

  # nix-homebrew: Manage Homebrew declaratively through Nix
  nix-homebrew = {
    enable = true;
    user = username;
    taps = {
      "homebrew/core" = inputs.homebrew-core;
      "homebrew/cask" = inputs.homebrew-cask;
      "homebrew/bundle" = inputs.homebrew-bundle;
    };
    enableRosetta = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {
      "WhatsApp" = 310633997;  
      "Home Assistant Companion" = 1099568401;
      "Perplexity" = 6714467650;
    };
    casks = [
      "cursor"
      "firefox"
      "ghostty"
      "font-google-sans-code"
      "raycast"
      "rectangle" 
      "chatgpt"
      "vlc"
      "spotify"
      "calibre"
      "tailscale-app"
      "bitwarden"
    ];
    taps = [];
    brews = [
      "uv" 
      "git-lfs"
      "hugo"
      "ollama"
    ];
  };
}
