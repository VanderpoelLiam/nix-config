{ pkgs, userConfig, ... }:
{
  users.users.${userConfig.global.username} = {
    isNormalUser = true;
    description = userConfig.global.gitName;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ userConfig.global.sshPublicKey ];
  };

  programs.zsh.enable = true;
}
