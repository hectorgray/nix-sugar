{ ... }:

{
  flake.homeModules.mutableFiles = { config, lib, ... }: {
    options = let
      mutableFile = file: {
        options.mutable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        config.force = lib.mkIf file.config.mutable (lib.mkForce true);
      };

      mkOpt = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule mutableFile);
      };
    in {
      home.file = mkOpt;

      xdg = lib.genAttrs
        [ "configFile" "dataFile" "stateFile" "cacheFile" ]
        (_: mkOpt);
    };

    config = let
      mutableFiles = config.home.file # xdg.*File entries are mapped here
        |> lib.attrValues
        |> lib.filter (file: file.enable && file.mutable);

      installMutableFile = file: /*bash*/ ''
        run install $VERBOSE_ARG -Dm0644 ${lib.escapeShellArg file.source} \
          "$HOME"/${lib.escapeShellArg file.target}
      '';
    in {
      home.activation.mutableFiles = lib.mkIf (mutableFiles != [ ])
        (lib.hm.dag.entryAfter [ "linkGeneration" ] (
          mutableFiles
            |> map installMutableFile
            |> lib.concatLines
        ));

      assertions = map (file: {
        assertion = file.executable != true;
        message = "${file.target}: `executable` and `mutable` are incompatible";
      }) mutableFiles;
    };
  };
}
