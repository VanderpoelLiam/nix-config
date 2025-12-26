{ ... }:
{
  home.file."Library/Application Support/Rectangle/RectangleConfig.json" = {
    source = ./config/rectangle-config.json;
    force = true;
  };
}

