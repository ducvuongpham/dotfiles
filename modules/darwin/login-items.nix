{ ... }:
{
  launchd.user.agents.monitorcontrol = {
    command = "/Applications/MonitorControl.app/Contents/MacOS/MonitorControl";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.maccy = {
    command = "/Applications/Maccy.app/Contents/MacOS/Maccy";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.mos = {
    command = "/Applications/Mos.app/Contents/MacOS/Mos";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };
}
