{ ... }:
{
  # Apps installed via nix systemPackages → /Applications/Nix Apps/. Stable path,
  # safe to point launchd at directly. Each app's own "Launch at Login" SMAppService
  # toggle should stay OFF to avoid double-launch.
  launchd.user.agents.maccy = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Nix Apps/Maccy.app/Contents/MacOS/Maccy" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.monitorcontrol = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Nix Apps/MonitorControl.app/Contents/MacOS/MonitorControl" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.mos = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Nix Apps/Mos.app/Contents/MacOS/Mos" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };
}
