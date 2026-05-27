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
          # data-sources.json embeds absolute home-dir paths (SSH key, mysql
          # client install dir) baked from the host that ran encrypt.sh. Rewrite
          # /Users/<author>/... → this host's $HOME so connections work without
          # per-machine forks of the encrypted file. Extend the sed list as new
          # author home-dirs show up.
          ${pkgs.gnused}/bin/sed -i \
            -e 's|/Users/pc391|${config.home.homeDirectory}|g' \
            "${dbeaverDir}/data-sources.json"
        fi
      '';
  };
}
