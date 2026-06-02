{ config, lib, pkgs, ... }:
let
  cfg = config.local.dbeaver;
  dbeaverDir = "${config.home.homeDirectory}/Library/DBeaverData/workspace6/General/.dbeaver";
in
{
  options.local.dbeaver.enable = lib.mkEnableOption ''
    Sync DBeaver connections + credentials from sops-encrypted files in
    secrets/dbeaver/ into the local DBeaver workspace on every home-manager
    activation. Dotfiles is the source of truth — run
    home/dbeaver/encrypt.sh to push local DBeaver changes back into the repo.
  '';

  config = lib.mkIf cfg.enable {
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      secrets = {
        dbeaver-credentials = {
          sopsFile = ../../secrets/dbeaver/credentials-config.enc;
          format = "binary";
        };
        dbeaver-data-sources = {
          sopsFile = ../../secrets/dbeaver/data-sources.enc;
          format = "binary";
        };
      };
    };

    # sops-nix's own activation runs:
    #   /bin/launchctl bootout  ... && true     # &&-true does NOT swallow failures
    #   /bin/launchctl bootstrap ...
    # On every rebuild this prints "Unrecognized target specifier" + "I/O error 5"
    # because the prior agent is still attached when bootstrap fires. Override
    # with a corrected version that suppresses the bootout failure and retries
    # bootstrap after a brief settle if the first attempt loses the race.
    home.activation.sops-nix = lib.mkForce (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        uid=$(id -u "$USER")
        plist="$HOME/Library/LaunchAgents/org.nix-community.home.sops-nix.plist"
        /bin/launchctl bootout "gui/$uid/org.nix-community.home.sops-nix" 2>/dev/null || true
        if ! /bin/launchctl bootstrap "gui/$uid" "$plist" 2>/dev/null; then
          sleep 0.3
          /bin/launchctl bootstrap "gui/$uid" "$plist"
        fi
      ''
    );

    home.activation.dbeaverSecretsSync =
      # Must run after sops-nix has decrypted the secrets — without this,
      # the source paths don't exist yet and the install commands no-op.
      lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
        mkdir -p "${dbeaverDir}"
        if [ -r "${config.sops.secrets.dbeaver-credentials.path}" ]; then
          install -m 0600 \
            "${config.sops.secrets.dbeaver-credentials.path}" \
            "${dbeaverDir}/credentials-config.json"
        fi
        if [ -r "${config.sops.secrets.dbeaver-data-sources.path}" ]; then
          install -m 0600 \
            "${config.sops.secrets.dbeaver-data-sources.path}" \
            "${dbeaverDir}/data-sources.json"
        fi
      '';
  };
}
