{
  pkgs,
  userConfig,
  ...
}: let
  cursorExtensions = [
    "vscodevim.vim"
    "ms-azuretools.vscode-docker"
  ];
in {
  # Don't change this when you change package input. Leave it alone.
  home = {
    stateVersion = "24.05";
    # specify my home-manager configs
    packages = with pkgs; [
      curl
      less
      tree
      oh-my-zsh
      zsh-powerlevel10k
      ripgrep
      fzf
      bat
      wget
      nodejs
      pnpm
      defaultbrowser
      duti
    ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "cursor";
    };
    file = {
      ".inputrc".source = ./dotfiles/inputrc;
      ".aliases".source = ./dotfiles/aliases; # Add your aliases file
      ".zshrc.local".source = ./dotfiles/zshrc; # Add your zshrc file
      ".p10k.zsh".source = ./dotfiles/p10k.zsh; # Powerlevel10k configuration
      ".config/ghostty/config".source = ./dotfiles/ghostty;
      "Library/Application Support/Cursor/User/settings.json" = {
        source = ./dotfiles/cursor-settings.json;
        force = true;
      };
    };
    activation = {
      installCursorExtensions = ''
        for ext_id in ${builtins.concatStringsSep " " cursorExtensions}; do
          /opt/homebrew/bin/cursor --install-extension "$ext_id"
        done
      '';
      setDefaultBrowser = ''
        ${pkgs.defaultbrowser}/bin/defaultbrowser firefox
      '';
      setDefaultTerminal = ''
        # Set ghostty as default terminal using duti
        if [ -d "/Applications/ghostty.app" ]; then
          ${pkgs.duti}/bin/duti -s com.ghostty.app public.unix-executable all 2>/dev/null || true
          ${pkgs.duti}/bin/duti -s com.ghostty.app public.shell-script all 2>/dev/null || true
          ${pkgs.duti}/bin/duti -s com.ghostty.app x-terminal-emulator all 2>/dev/null || true
        fi
      '';
    };
  };
  programs = {
    bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user.name = userConfig.gitName;
        user.email = userConfig.gitEmail;
        safe.directory = "*";
        merge.tool = "opendiff";
        diff.tool = "opendiff";
        difftool.prompt = false;
        difftool."opendiff" = ''cmd = /usr/bin/opendiff "$LOCAL" "$REMOTE" -merge "$MERGED" | cat'';
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

      initContent = ''
        # Add ~/.local/bin to the path array
        path=("$HOME/.local/bin" $path)
        source ~/.p10k.zsh
      '';

      shellAliases = {
        ls = "ls --color=auto -F";
        nixswitch = "sudo -i darwin-rebuild switch --flake \"$HOME/nix-config#${userConfig.hostname}\"";
        nixup = "(cd ~/nix-config && nix flake update --extra-experimental-features 'nix-command flakes' && nixswitch)";
      };

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = ["git" "docker"];
      };
    };
  };
}
