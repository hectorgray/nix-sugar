{ inputs, lib, ... }:

{
  imports = [ inputs.flake-parts.flakeModules.flakeModules ];

  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
}
