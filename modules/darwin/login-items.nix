{ ... }:
{
  launchd.user.agents.monitorcontrol = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/MonitorControl.app/Contents/MacOS/MonitorControl" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.maccy = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Maccy.app/Contents/MacOS/Maccy" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.mos = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Mos.app/Contents/MacOS/Mos" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };
}
