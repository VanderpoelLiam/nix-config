{ hostname, ... }:
{
  programs.zsh.shellAliases = {
    nixswitch = "sudo -i darwin-rebuild switch --flake \"$HOME/nix-config#${hostname}\"";
    nixup = "(cd ~/nix-config && nix flake update --extra-experimental-features 'nix-command flakes' && nixswitch)";
    nixgc = "nix-collect-garbage --delete-older-than 10d";
  };
}
