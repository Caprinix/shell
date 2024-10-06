{config, lib, ...}:
{
    options.vscode = {
        enable = lib.mkEnableOption "vscode editor";
        package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.vscode-fhs;
            defaultText = lib.literalExpression "pkgs.vscode-fhs";
            description = "The Vscode package to use";
        };
        extensions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            defaultText = lib.literalExpression "[]";
            description = "Which extensions to add to vscode";
        };
        extension-mixins = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            defaultText = lib.literalExpression "[]";
            description = "Which extension-mixins to add to vscode";
        };
    }
}   