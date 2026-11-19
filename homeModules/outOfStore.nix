{ ... }:

{
  flake.homeModules.outOfStore = { self }: { config, lib, ... }: {
    options = let
      outOfStoreFile = {
        options.outOfStore = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };

      homeFile = file: {
        options.source = lib.mkOption {
          apply = source: let
            path = toString source;
          in
            if !file.config.outOfStore then
              source
            else if lib.hasPrefix "${self}/" path then
              config.lib.file.mkOutOfStoreSymlink
                "${config.home.flakeRoot}/${lib.removePrefix "${self}/" path}"
            else
              config.lib.file.mkOutOfStoreSymlink source;
        };
      };

      mkOpt = modules: lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule modules);
      };
    in {
      home.flakeRoot = lib.mkOption { type = lib.types.str; };
      home.file = mkOpt [ outOfStoreFile homeFile ];

      xdg = lib.genAttrs
        [ "configFile" "dataFile" "stateFile" "cacheFile" ]
        (_: mkOpt outOfStoreFile);
    };

    config = let
      outOfStoreFiles = config.home.file # xdg.*File entries are mapped here
        |> lib.attrValues
        |> lib.filter (file: file.enable && file.outOfStore);
    in {
      assertions = lib.concatMap (file: [{
        assertion = !(file.mutable or false);
        message = "${file.target}: `outOfStore` and `mutable` are incompatible";
      } {
        assertion = file.text == null;
        message = "${file.target}: `outOfStore` and `text` are incompatible";
      }]) outOfStoreFiles;
    };
  };
}
