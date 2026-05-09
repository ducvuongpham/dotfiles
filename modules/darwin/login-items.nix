{ ... }:
{
  launchd.user.agents.monitorcontrol = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Nix Apps/MonitorControl.app/Contents/MacOS/MonitorControl" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.maccy = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Nix Apps/Maccy.app/Contents/MacOS/Maccy" ];
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
