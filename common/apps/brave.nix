{ ... }:

{
  programs.brave = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "ecabifbgmdmgdllomnfinbmaellmclnh"; } # Reader View
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "eiaeiblijfjekdanodkjadfinkhbfgcd"; } # NordPass
    ];
    # Same Wayland & GPU flags as Chromium
    commandLineArgs = [
      "--ozone-platform-hint=wayland"
      "--enable-features=VaapiVideoDecodeLinuxGL,AcceleratedVideoEncoder"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--ignore-gpu-blacklist"
    ];
  };
}
