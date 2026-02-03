{ userConfig, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = userConfig.global.gitName;
      user.email = userConfig.global.gitEmail;
      safe.directory = "*";
      merge.tool = "opendiff";
      diff.tool = "opendiff";
      difftool.prompt = false;
      difftool."opendiff" = ''cmd = /usr/bin/opendiff "$LOCAL" "$REMOTE" -merge "$MERGED" | cat'';
    };
  };
}

