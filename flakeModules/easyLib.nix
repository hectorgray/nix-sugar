{ lib, flake-parts-lib, ... }:

let
  inherit (lib.types) either lazyAttrsOf;

  functionType = lib.mkOptionType {
    name = "function";
    check = builtins.isFunction;
    merge = lib.mergeOneOption;
  };

  functionTreeType = either functionType (lazyAttrsOf functionTreeType);

  libOption = lib.mkOption {
    type = lazyAttrsOf functionTreeType;
    default = {};
  };

  module = {
    options.flake.lib = libOption;
    options.perSystem = flake-parts-lib.mkPerSystemOption {
      options.lib = libOption;
    };

    config.transposition.lib = {};
  };
in

{
  imports = [ module ]; # dogfood
  flake.flakeModules.easyLib = module;
}
