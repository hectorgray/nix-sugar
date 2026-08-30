# Nix Sugar

Miscellaneous Nix expressions.

## Requirements

Ensure the following are enabled in your Nix configuration:

```nix
nix.settings.experimental-features = [
  "flakes"
  "nix-command"
  "pipe-operators"
];
```

Then add to your inputs:

```nix
inputs.sugar = {
  url = "github:hectorgray/nix-sugar";

  # Optional
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
};
```

## Functions

### `listTree`

```
listTree :: Path -> [String]
```

Recursively list all `.nix` files under a directory, skipping `flake.nix` and
paths prefixed with `.` or `_`.

#### Example

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [ "x86_64-linux" ];
  imports = inputs.sugar.lib.listTree ./.;
};
```

> [!NOTE]
> Examples below may assume this flake setup (`flake-parts` + `listTree`),
> though the features should still work without it.

**Related:**

- [denful/import-tree](https://github.com/denful/import-tree)

## Flake Modules

### `easyLib`

```nix
imports = [ inputs.sugar.flakeModules.easyLib ];
```

Merge `flake.lib` across modules as a lazy attribute set of functions
(type-checked), so any module can contribute one without declaring an option
for it. Two modules contributing the same name is an error.

This is a plain module designed to work well with `flake-parts`, which exposes
`flake.lib` as the output `lib`.

#### Example

```nix
# greet.nix
{ flake.lib.greet = name: "Hello, ${name}!"; }
```

```nix
# square.nix
{ flake.lib.square = x: x * x; }
```

## Home Modules

### `mimeGlobs`

```nix
imports = [ inputs.sugar.homeModules.mimeGlobs ];
```

Add glob variants of the `xdg.mimeApps` association options. Keys ending in `*`
expand against every MIME type known to `shared-mime-info` and exact keys
clobber glob matches.

#### Example

```nix
xdg.mimeApps = {
  enable = true;

  globs.defaultApplications = {
    "text/*" = "nvim.desktop";
    "text/html" = "firefox.desktop";
  };
};
```
