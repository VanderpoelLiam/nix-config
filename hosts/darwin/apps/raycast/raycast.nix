{ pkgs, lib, ... }:
{
  # Raycast is installed via Homebrew cask, so we just configure it here
  
  home.activation.configureRaycast = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Configure Raycast settings deterministically
    # Set Cmd+Space as the global hotkey (Command-49 = Cmd+Space)
    /usr/bin/defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"
    
    # Enable Raycast to launch on login
    /usr/bin/defaults write com.raycast.macos launchAtLogin -bool true
    
    # Set Raycast as the default launcher (disable Spotlight shortcuts)
    # This ensures Raycast can use Cmd+Space without conflicts
    PLIST="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
    
    # Ensure the plist exists and has the required structure
    if [ ! -f "$PLIST" ]; then
      /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict
    fi
    
    # Disable Cmd+Space (Spotlight) - hotkey 64
    # Create the entry structure if it doesn't exist, then set enabled to false
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64 dict" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64:enabled bool false" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" "$PLIST"
    
    # Disable Cmd+Option+Space (Spotlight in Finder) - hotkey 65
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:65 dict" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:65:enabled bool false" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled false" "$PLIST"
    
    # Reload preferences to apply changes
    /usr/bin/killall cfprefsd 2>/dev/null || true
    
    # Kill Spotlight to force it to restart with new settings
    /usr/bin/killall Spotlight 2>/dev/null || true
    
    # Also restart Dock to ensure keyboard shortcuts are reloaded
    /usr/bin/killall Dock 2>/dev/null || true
  '';
}

