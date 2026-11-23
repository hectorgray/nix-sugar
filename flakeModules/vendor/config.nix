{ ... }:

{
  flake.flakeModules.vendor = { self, ... }: {
    perSystem = { config, lib, pkgs, ... }: {
      apps = lib.mkIf (config.vendor.targets != { }) {
        vendor = {
          type = "app";
          meta.description = "Update vendored files from declared sources";

          program = lib.getExe (pkgs.writeShellApplication {
            name = "vendor";
            runtimeInputs = [ pkgs.coreutils pkgs.diffutils ];

            text = ''
              rootMarker=${lib.escapeShellArg config.vendor.rootMarker}
            '' + builtins.readFile ./vendor.sh + "\n" + (
              config.vendor.targets
              |> lib.mapAttrsToList (path: source: ''
                vendor ${lib.escapeShellArgs [ path source ]}
              '')
              |> lib.concatStrings
            );
          });
        };
      };

      checks = lib.mapAttrs' (path: source: {
        name = "vendor:${path}";

        value = pkgs.runCommandLocal "vendor-check" { } ''
          source=${lib.escapeShellArg source}
          destination=${lib.escapeShellArg "${self}/${path}"}

          if [ -d "$source" ]; then
            test -d "$destination"
          else
            test -f "$destination"
          fi

          diff -ru "$source" "$destination"
          touch "$out"
        '';
      }) config.vendor.targets;
    };
  };
}
