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

  launchd.user.agents.clipy = {
    command = "/Applications/Clipy.app/Contents/MacOS/Clipy";
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
