{
  description = "Safe containerized Node.js dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dev-templates.url = "github:the-nix-way/dev-templates";
  };

  outputs = {
    self,
    nixpkgs,
    dev-templates,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    lib = dev-templates.lib;

    image = lib.mkContainerImage {
      inherit pkgs;
      extraPackages = [pkgs.nodejs];
    };

    runScript = lib.mkContainerRunScript {inherit pkgs image;};
    wrapCmd = lib.mkContainerWrapCmd {inherit pkgs runScript;};
  in {
    packages.${system}.image = image;

    apps.${system}.safe-run = {
      type = "app";
      program = "${runScript}/bin/safe-run";
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        runScript
        (wrapCmd "npm")
        (wrapCmd "npx")
        (wrapCmd "node")
      ];
    };
  };
}
