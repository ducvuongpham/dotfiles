{ ... }:
{
  # Apps installed via nix systemPackages → /Applications/Nix Apps/. Stable path,
  # safe to point launchd at directly. Each app's own "Launch at Login" SMAppService
  # toggle should stay OFF to avoid double-launch.
  # KeepAlive.SuccessfulExit=false → launchd auto-restarts on crash but
  # leaves the agent alone on a clean user-initiated quit. With the old
  # KeepAlive=false, if the app lost the race with WindowServer/Dock at
  # boot and crashed once, launchd never retried until next login —
  # hence Maccy "sometimes not auto-starting". ThrottleInterval avoids
  # a crash-loop hammer. LimitLoadToSessionType=Aqua skips loading in
  # SSH-only sessions.
  launchd.user.agents.maccy = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Nix Apps/Maccy.app/Contents/MacOS/Maccy" ];
      RunAtLoad = true;
      KeepAlive = { SuccessfulExit = false; };
      ThrottleInterval = 5;
      LimitLoadToSessionType = "Aqua";
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.mos = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Nix Apps/Mos.app/Contents/MacOS/Mos" ];
      RunAtLoad = true;
      KeepAlive = { SuccessfulExit = false; };
      ThrottleInterval = 5;
      LimitLoadToSessionType = "Aqua";
      ProcessType = "Interactive";
    };
  };
}
