{ pkgs, hostname, ... }:
{
  home.file = {
    ".inputrc".source = ./config/inputrc;
    ".aliases".source = ./config/aliases;
    ".zshrc.local".source = ./config/zshrc;
    ".p10k.zsh".source = ./config/p10k.zsh;
  };

  programs.zsh = {
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
      nixswitch = "sudo -i darwin-rebuild switch --flake \"$HOME/nix-config#${hostname}\"";
      nixup = "(cd ~/nix-config && nix flake update --extra-experimental-features 'nix-command flakes' && nixswitch)";
      nixgc = "nix-collect-garbage --delete-older-than 10d";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = ["git" "docker"];
    };
  };
}

