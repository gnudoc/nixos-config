{ ... }:

{
  programs.git = {
    enable = true;
    # This include is so that we don't have infrastruc details on public gh
    includes = [ { path = "~/.config/git/config.local"; } ];
    settings = {
      core.autocrlf = "input";
      github.user = "gnudoc";
    };
    signing.signByDefault = true;
  };
}
