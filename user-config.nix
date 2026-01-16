{
  # Global settings (all machines)
  global = {
    username = "liam";
    gitName = "Liam Vanderpoel";
    gitEmail = "vanderpoel.liam@gmail.com";
    timezone = "Europe/Zurich";
    baseDomain = "vanderpoel.ch";
  };

  # Per-machine settings
  machines = {
    "Liams-MacBook-Pro" = {
      system = "aarch64-darwin";
    };
    "trantor" = {
      system = "x86_64-linux";
      disk = "/dev/sda";
    };
    "hyperion" = {
      system = "x86_64-linux";
      disk = "/dev/sda";
    };
  };
}
