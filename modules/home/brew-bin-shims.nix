{ config, lib, ... }:
# Expose selected nix-installed binaries to GUI apps (Raycast extensions,
# Spotlight launches, etc.) by symlinking them into /opt/homebrew/bin.
#
# Why: macOS launchd starts GUI apps with a minimal PATH that doesn't
# include the nix profile (/etc/profiles/per-user/<user>/bin). Many tools
# only probe Homebrew's bin on Apple Silicon, so they report the binary
# as missing even though `which` finds it in your shell.
#
# Symlinks point at config.home.profileDirectory so they track whichever
# version of the package is currently installed via home.packages. If a
# package is later removed, the symlink will dangle harmlessly until the
# next switch (you can prune it then).
let
  shims = [ "yt-dlp" "ffmpeg" "ffprobe" ];
  brewBin = "/opt/homebrew/bin";
in
{
  home.activation.brewBinShims = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${brewBin}" ] && [ -w "${brewBin}" ]; then
      ${lib.concatMapStringsSep "\n" (name: ''
        src="${config.home.profileDirectory}/bin/${name}"
        dst="${brewBin}/${name}"
        if [ -e "$src" ]; then
          if [ -L "$dst" ] || [ ! -e "$dst" ]; then
            ln -sfn "$src" "$dst"
          fi
        fi
      '') shims}
    fi
  '';
}
