{ ... }:
{
  home.file."Library/Application Support/Rectangle/RectangleConfig.json" = {
    source = ./config.json;
    force = true;
  };
}

