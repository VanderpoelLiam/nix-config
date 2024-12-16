{
  pkgs,
  ...
}: {
  # Don't change this when you change package input. Leave it alone.
  home = {
    stateVersion = "24.05";
    # specify my home-manager configs
    packages = with pkgs; [
      curl # Command line tool for transferring data with URLs
      less # Terminal pager for viewing file contents
      tree # Directory listing in tree-like format
      oh-my-zsh # Framework for managing zsh configuration
      zsh-powerlevel10k # Modern, fast zsh theme
      ripgrep # Fast grep alternative written in Rust
      fzf # Command-line fuzzy finder
      bat # Cat clone with syntax highlighting and git integration
      wget
    ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "code";
    };
    file = {
      ".inputrc".source = ./dotfiles/inputrc;
      ".aliases".source = ./dotfiles/aliases; # Add your aliases file
      ".zshrc.local".source = ./dotfiles/zshrc; # Add your zshrc file
    };
  };
  programs = {
    bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "master";
        user.name = "Liam Vanderpoel";
        user.email = "liam@superlinear.com";
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

      initExtra = ''
        source ~/.p10k.zsh
      '';

      shellAliases = {
        ls = "ls --color=auto -F";
        g = "git";
        nixswitch = "darwin-rebuild switch --flake ~/nix-config/.#";
        nixup = "pushd ~/nix-config; nix flake update; nixswitch; popd";
      };

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = ["git" "docker"];
      };
    };
    vscode = {
      enable = true;

      # Specify extensions
      extensions = with pkgs.vscode-extensions; [
        # ms-vscode-remote.remote-containers
        ms-vscode.makefile-tools
        # ms-python.python
        editorconfig.editorconfig
        mhutchie.git-graph
        njpwerner.autodocstring
        # GitHub.vscode-pull-request-github
        # GitHub.copilot
        charliermarsh.ruff
        streetsidesoftware.code-spell-checker
        # p403n1x87.austin-vscode
        eamodio.gitlens
        vscodevim.vim
      ];
      userSettings = {
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "git.autofetch" = true;
        "files.autoSave" = "afterDelay";
        "explorer.confirmDragAndDrop" = false;
        "keyboard.dispatch" = "keyCode";
        "editor.formatOnSave" = true;
        "vim.smartRelativeLine" = true;
        "explorer.confirmDelete" = false;
        "workbench.colorTheme" = "Visual Studio Light";
        "terminal.integrated.enableMultiLinePasteWarning" = false;
        "editor.fontFamily" = "'Droid Sans Mono', 'monospace', monospace";
        "terminal.integrated.fontFamily" = "MesloLGLDZ Nerd Font";
        "terminal.integrated.fontSize" = 16;
        "python.testing.pytestArgs" = ["tests"];
        "python.testing.unittestEnabled" = false;
        "python.testing.pytestEnabled" = true;
      };
    };
  };
}
