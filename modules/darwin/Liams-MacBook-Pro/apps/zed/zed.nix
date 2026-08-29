{ ... }:
{
  home.file.".config/zed/settings.json" = {
    source = ./config.json;
    force = true;
  };

  home.file.".config/zed/keymap.json" = {
    source = ./keymap.json;
    force = true;
  };
}
