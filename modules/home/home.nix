{ pkgs, ... }:
{
  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "24.05";

  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    EDITOR = "cursor";
  };

  home.packages = with pkgs; [
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
    uv
    git-lfs
  ];
}

