{ inputs, outputs, config, lib, hostname, system, username, pkgs, ... }:
{
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
      menuExtraClock = {
        Show24Hour = true;
        ShowDayOfWeek = true;
      };
      # 18 = show in menu bar, 24 = hide from menu bar
      CustomUserPreferences = {
        "com.apple.controlcenter" = {
          Bluetooth = 24;
          AirDrop = 24;
          Display = 24;
          Sound = 24;
          NowPlaying = 24;
          FocusModes = 24;
        };
        "com.apple.TextInputMenu" = {
          visible = false;
        };
        "com.apple.Spotlight" = {
          MenuItemHidden = 1;
        };
      };
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}


