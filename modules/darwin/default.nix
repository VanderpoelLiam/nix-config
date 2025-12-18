{pkgs, inputs, ...}: {
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
  nix.settings.experimental-features = "nix-command flakes";
  nix.enable = false;

  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    primaryUser = "liam";
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

  # nix-homebrew: Manage Homebrew declaratively through Nix
  nix-homebrew = {
    enable = true;
    user = "liam";
    taps = {
      "homebrew/core" = inputs.homebrew-core;
      "homebrew/cask" = inputs.homebrew-cask;
      "homebrew/bundle" = inputs.homebrew-bundle;
    };
    enableRosetta = true;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {};
    casks = [
      # Development
      "docker-desktop" # docker desktop app
      "warp"
      "cursor"

      # Browsers & Communication
      "firefox"

      # Productivity & Utils
      "raycast"
      "rectangle" # window manager
      "chatgpt"

      # System & Utilities
      "aldente" # Battery management

      # Media & Entertainment
      "vlc" # Media player
      "spotify"
      "calibre" # E-book management and conversion
    ];
    taps = [];
    brews = [
      "uv" # An extremely fast Python package installer and resolver
      "git-lfs"
      "pandoc"
      "pdftk-java"
      "act"
      "hugo"
      "ollama"
    ];
  };
}
