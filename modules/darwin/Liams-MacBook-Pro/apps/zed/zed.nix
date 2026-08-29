{ ... }:
{
  home.file.".config/zed/settings.json" = {
    source = ./config.json;
    force = true;
  };
}
