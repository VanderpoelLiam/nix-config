{ pkgs, userConfig, ... }:
{
  users.users.${userConfig.global.username} = {
    isNormalUser = true;
    description = userConfig.global.gitName;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
