{ lib, modulesPath, pkgs, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
  ];

  # AMD Ryzen 5 5600G iGPU (Vega 7)
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
