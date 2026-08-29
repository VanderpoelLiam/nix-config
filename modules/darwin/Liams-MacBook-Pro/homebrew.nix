{ inputs, outputs, config, lib, hostname, system, username, pkgs, ... }:
{
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
    global.brewfile = true;
    masApps = {
      "WhatsApp" = 310633997;  
      "Home Assistant Companion" = 1099568401;
      "Trello" = 1278508951;
    };
    casks = [
      "zed"
      "firefox"
      "ghostty"
      "font-atkinson-hyperlegible-mono"
      "rectangle" 
      "calibre"
      "vlc"
      "spotify"
      "bitwarden"
      "tailscale-app"
      "raycast"
      "claude-code"
      "claude"
    ];
    taps = [];
    brews = [
      "hugo"
      "ollama"
    ];
  };
}

