{
  inputs,
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.vscode;
  extensionMixins = (
    if
      (builtins.hasAttr "caprinix-config" inputs)
      && (builtins.pathExists "${inputs.caprinix-config}/extension-mixins.json")
    then
      builtins.fromJSON (builtins.readFile ("${inputs.caprinix-config}/extension-mixins.json"))
    else
      { base = { }; }
  );
  mixinExtensions = builtins.map (mixin: extensionMixins.${mixin}) (cfg.mixins ++ [ "base" ]);
  allExtensionStrings = lib.unique (lib.lists.flatten (mixinExtensions ++ cfg.extensions));
  stringToPackage =
    string:
    let
      stringParts = lib.splitString "." string;
    in
    pkgs-unstable.vscode-marketplace.${lib.elemAt stringParts 0}.${lib.elemAt stringParts 1};
  allExtensionPackages = map stringToPackage allExtensionStrings;
in
{
  options.vscode = {
    enable = lib.mkEnableOption "vscode editor";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs-unstable.vscode-fhs;
      defaultText = lib.literalExpression "pkgs.vscode-fhs";
      description = "The Vscode package to use";
    };
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      defaultText = lib.literalExpression "[]";
      description = "Which extensions to add to vscode";
    };
    mixins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      defaultText = lib.literalExpression "[]";
      description = "Which extension-mixins to add to vscode";
    };
    overrideInDevcontainer = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    packages = with pkgs-unstable; [
      (vscode-with-extensions.override {
        vscode = cfg.package;
        vscodeExtensions = allExtensionPackages;
      })
    ];
    devcontainer.settings.customizations.vscode.extensions = lib.mkIf cfg.overrideInDevcontainer allExtensionStrings;
  };
}
