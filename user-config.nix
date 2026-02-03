{
  # Global settings (all machines)
  global = {
    username = "liam";
    gitName = "Liam Vanderpoel";
    gitEmail = "vanderpoel.liam@gmail.com";
    timezone = "Europe/Zurich";
    baseDomain = "vanderpoel.ch";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLV9haBVJD2MglYxfIYY1CsZ2w4NI8yw1Rw1tC88A5X liam@Liams-MacBook-Pro";
  };

  # Per-machine settings
  machines = {
    "Liams-MacBook-Pro" = {
      system = "aarch64-darwin";
    };
    "hyperion" = {
      system = "x86_64-linux";
    };
  };
}
