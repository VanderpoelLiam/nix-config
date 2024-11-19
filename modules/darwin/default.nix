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

  security.pam.enableSudoTouchIdAuth = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  fonts.packages = [(pkgs.nerdfonts.override {fonts = ["Meslo"];})];
  services.nix-daemon.enable = true;
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder._FXShowPosixPathInTitle = true;
    dock.autohide = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {};
    casks = [
      # Development
      "docker" # docker desktop app
      "github" # github desktop app
      "warp"
      "visual-studio-code"

      # Browsers & Communication
      "firefox"
      "slack"

      # Productivity & Utils
      "raycast"
      "rectangle" # window manager
      "chatgpt"

      # System & Utilities
      "aldente" # Battery management
      "tomatobar" # Focus timer

      # Media & Entertainment
      "vlc" # Media player
    ];
    taps = [];
    brews = [
      "poetry"
      "pyenv"
      "pyenv-virtualenv"
    ];
  };
}
