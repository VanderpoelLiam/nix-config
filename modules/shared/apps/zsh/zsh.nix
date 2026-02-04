{ pkgs, ... }:
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
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = ["git" "docker"];
    };
  };
}

