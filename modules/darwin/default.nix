{pkgs, ...}: {
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
          "/Applications/Visual Studio Code.app"
          "/Applications/ChatGPT.app"
          "/Applications/Slack.app"
          "/System/Applications/System Settings.app"
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

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {};
    casks = [
      # Development
      "docker-desktop" # docker desktop app
      "github" # github desktop app
      "warp"
      "visual-studio-code"
      "cursor"
      "zed"

      # Browsers & Communication
      "firefox"
      "slack"

      # Productivity & Utils
      "raycast"
      "rectangle" # window manager
      "chatgpt"
      "claude"
      "notion-calendar"
      "obsidian"

      # System & Utilities
      "aldente" # Battery management
      "tomatobar" # Focus timer

      # Media & Entertainment
      "vlc" # Media player
      "spotify"
      "calibre" # E-book management and conversion
    ];
    taps = [];
    brews = [
      "poetry"
      "uv" # An extremely fast Python package installer and resolver
      "git-lfs"
      "pandoc"
      "pdftk-java"
      "act"
      "hugo"
      "ollama"
      # Tauri iOS development tools
      "cocoapods" # iOS dependency manager (pod install)
      "xcodegen" # Generates Xcode projects
      "ios-deploy" # Deploy apps to physical iOS devices
      "libimobiledevice" # Communicate with iOS devices
    ];
  };
}
