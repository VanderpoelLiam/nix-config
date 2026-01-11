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
    bat
    curl
    fzf
    git-lfs
    just
    less
    oh-my-zsh
    ripgrep
    tree
    uv
    wget
    zsh-powerlevel10k
  ];
}

