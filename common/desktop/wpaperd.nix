{ config, ... }:

{
  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        # can change default to a specific monitor name
        path = "${config.home.homeDirectory}/.local/share/wallpapers";
        duration = "5m";
        mode = "center"; # or fit, or fill
        sorting = "random";
      };
    };
  };
}
