{ ... }:

{
  flake.homeModules.mimeGlobs = { config, lib, pkgs, ... }: let
    allTypes = "${pkgs.shared-mime-info}/share/mime/types"
      |> builtins.readFile
      |> lib.splitString "\n"
      |> builtins.filter (s: s != "");
    # -> [ "text/html" "text/plain" "video/mp4" ... ]

    expandGlob = glob: app: # "text/*" -> "foo.desktop"
      allTypes
      |> builtins.filter (lib.hasPrefix (lib.removeSuffix "*" glob))
      |> lib.flip lib.genAttrs (_: app);
    # -> { "text/html" = "foo.desktop"; "text/plain" = "foo.desktop"; ... }

    expand = attrs: let # { "text/*" = "foo.desktop"; "text/html" = "bar.desktop" }
      globAttrs = lib.filterAttrs (k: _v: lib.hasSuffix "*" k) attrs;
      exactAttrs = lib.filterAttrs (k: _v: !(lib.hasSuffix "*" k)) attrs;
    in
      globAttrs
      |> lib.mapAttrsToList expandGlob
      |> lib.mergeAttrsList
      |> (acc: acc // exactAttrs); # rhs wins on conflicts
    # -> { "text/plain" = "foo.desktop"; ...; "text/html" = "bar.desktop" }
  in {
    options.xdg.mimeApps.globs = let
      strListOrSingleton = with lib.types; # definition from hm src
        coercedTo (either (listOf str) str) lib.toList (listOf str);

      mkOpt = lib.mkOption {
        type = lib.types.attrsOf strListOrSingleton;
        default = { };
      };
    in {
      defaultApplications = mkOpt;
      associations.added = mkOpt;
      associations.removed = mkOpt;
    };

    config.xdg.mimeApps = let
      cfg = config.xdg.mimeApps.globs;
    in {
      defaultApplications  = expand cfg.defaultApplications;
      associations.added   = expand cfg.associations.added;
      associations.removed = expand cfg.associations.removed;
    };
  };
}
