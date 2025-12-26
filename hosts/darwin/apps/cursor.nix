{ pkgs, ... }:
let
  cursorExtensions = [
    "vscodevim.vim"
    "ms-azuretools.vscode-docker"
  ];
in
{
  home.file."Library/Application Support/Cursor/User/settings.json" = {
    source = ./config/cursor-settings.json;
    force = true;
  };

  home.activation.installCursorExtensions = ''
    for ext_id in ${builtins.concatStringsSep " " cursorExtensions}; do
      /opt/homebrew/bin/cursor --install-extension "$ext_id"
    done
  '';
}

