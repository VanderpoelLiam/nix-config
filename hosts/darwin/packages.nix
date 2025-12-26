{ pkgs, ... }:
{
  home.packages = with pkgs; [
    defaultbrowser
    duti
  ];

  home.activation = {
    setDefaultBrowser = ''
      ${pkgs.defaultbrowser}/bin/defaultbrowser firefox
    '';
    setDefaultTerminal = ''
      # Set ghostty as default terminal using duti
      if [ -d "/Applications/ghostty.app" ]; then
        ${pkgs.duti}/bin/duti -s com.ghostty.app public.unix-executable all
        ${pkgs.duti}/bin/duti -s com.ghostty.app public.shell-script all
        ${pkgs.duti}/bin/duti -s com.ghostty.app x-terminal-emulator all
      fi
    '';
  };
}

