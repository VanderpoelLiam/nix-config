{ pkgs, ... }:
{
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
  ];
}

