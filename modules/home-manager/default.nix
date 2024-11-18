{
  pkgs,
  nvim,
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
      # poetry
      ripgrep # Fast grep alternative written in Rust
      fzf # Command-line fuzzy finder
      bat # Cat clone with syntax highlighting and git integration
      nvim.packages."aarch64-darwin".default
    ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
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
        user.email = "vanderpoel.liam@gmail.com";
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
  };
}
