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
      "font-atkinson-hyperlegible-mono"
      "rectangle" 
      "chatgpt"
      "calibre"
      "vlc"
      "spotify"
      "bitwarden"
      "tailscale-app"
      "raycast"
    ];
    taps = [];
    brews = [
      "hugo"
      "ollama"
    ];
  };
}

