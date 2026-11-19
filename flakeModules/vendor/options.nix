{ lib, flake-parts-lib, ... }:

{
  flake.flakeModules.vendor = { ... }: {
    options.perSystem = flake-parts-lib.mkPerSystemOption {
      options.vendor = {
        rootMarker = lib.mkOption {
          type = lib.types.str;
          default = "flake.nix";
        };

        targets = lib.mkOption {
          type = lib.types.attrsOf lib.types.pathInStore;
          default = { };

          apply = targets: let
            rules = path:
              path != ""
              && !lib.hasPrefix "/" path
              && !lib.hasPrefix "-" path
              && lib.all (p: p != ".." && p != ".") (lib.splitString "/" path);
          in
            assert (
              targets
              |> builtins.attrNames
              |> lib.all rules
              |> lib.flip lib.assertMsg "vendor: invalid destination path"
            ); targets;
        };
      };
    };
  };
}
