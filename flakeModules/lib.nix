{ lib, ... }:

let
  module.options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.mkOptionType {
      name = "function";
      check = lib.isFunction;
      merge = lib.mergeOneOption;
    });
  };
in

{
  imports = [ module ];
  flake.flakeModules.lib = module;
}

