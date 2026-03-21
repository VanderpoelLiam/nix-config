{ userConfig, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = userConfig.global.gitName;
      user.email = userConfig.global.gitEmail;
      safe.directory = "*";
    };
  };
}

