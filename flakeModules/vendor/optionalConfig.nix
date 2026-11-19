{ ... }:

{
  flake.flakeModules.vendor = { ... }: {
    perSystem = { config, lib, options, ... }: {
      config = lib.optionalAttrs (options ? treefmt) {
        treefmt.settings.excludes = lib.mapAttrsToList (
          path: source:
            if lib.filesystem.pathIsDirectory source then "${path}/**" else path
        ) config.vendor.targets;
      };
    };
  };
}
