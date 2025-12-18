let
  extensions = [
    {
      name = "vim";
      publisher = "vscodevim";
    }
    {
      name = "vscode-docker";
      publisher = "ms-azuretools";
    }
  ];
  extensionIds = map (e: "''${e.publisher}.''${e.name}") extensions;
  extensionsList = builtins.concatStringsSep " " extensionIds;
in {
  home.file."Library/Application Support/Cursor/User/extensions.json" = {
    text = builtins.toJSON { recommendations = extensionIds; };
  };

  home.activation.installCursorExtensions = ''
    CURSOR_CMD=""
    for path in "/opt/homebrew/bin/cursor" "/usr/local/bin/cursor" "$HOME/.local/bin/cursor"; do
      [ -f "$path" ] && [ -x "$path" ] && CURSOR_CMD="$path" && break
    done
    
    [ -z "$CURSOR_CMD" ] && command -v cursor >/dev/null 2>&1 && CURSOR_CMD=$(command -v cursor)
    
    [ -z "$CURSOR_CMD" ] || [ ! -x "$CURSOR_CMD" ] && exit 0
    ! "$CURSOR_CMD" --version >/dev/null 2>&1 && exit 0
    
    INSTALLED_EXTS=$("$CURSOR_CMD" --list-extensions 2>/dev/null || echo "")
    
    for ext_id in ${extensionsList}; do
      if echo "$INSTALLED_EXTS" | grep -q "^$ext_id$"; then
        echo "  ✓ $ext_id already installed"
      else
        echo "  Installing $ext_id..."
        "$CURSOR_CMD" --install-extension "$ext_id" >/dev/null 2>&1 && echo "  ✓ Installed $ext_id" || echo "  ✗ Failed $ext_id"
      fi
    done
  '';
}

