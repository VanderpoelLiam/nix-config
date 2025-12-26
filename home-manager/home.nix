{ pkgs, ... }:
{
  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "24.05";

  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    EDITOR = "cursor";
  };
}

