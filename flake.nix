{
  description = "Modern modular macOS configuration with nix-darwin + home-manager + yabai";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ashpipe = {
      url = "github:KirisameLonnet/ashpipe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ashpipe,
    }:
    let
      system = "aarch64-darwin";

      # Custom packages configuration
      pkgsConfig = {
        allowUnfree = true;
      };

      pkgsOverlays = [
        # Darwin compatibility for packages that depend on unity-test.
        (_: prev: {
          # unity-test fails its C++-compiled tests on darwin; skip checks to keep dependents building.
          unity-test = prev.unity-test.overrideAttrs (_: {
            doCheck = false;
          });

          # Upgrade ONLY claude-code ahead of the pinned nixpkgs, without bumping
          # the whole nixpkgs input. To bump again: set version + the darwin-arm64
          # sha256 from https://downloads.claude.ai/claude-code-releases/<ver>/... .
          claude-code = prev.claude-code.overrideAttrs (_: rec {
            version = "2.1.220";
            src = prev.fetchurl {
              url = "https://downloads.claude.ai/claude-code-releases/${version}/darwin-arm64/claude";
              sha256 = "8addc857f3fe64d5a0368af9ee50321b50afb4a6918ba3ef018ab84f5dbbe081";
            };
          });

          # VS Code 1.129 moved the bundled ripgrep binary into the unpacked ASAR tree.
          vscode = prev.vscode.overrideAttrs (old: {
            postPatch =
              builtins.replaceStrings
                [ "Contents/Resources/app/node_modules/@vscode/ripgrep-universal" ]
                [ "Contents/Resources/app/node_modules.asar.unpacked/@vscode/ripgrep-universal" ]
                old.postPatch;
          });
        })
      ];

      pkgs = import nixpkgs {
        inherit system;
        config = pkgsConfig;
        overlays = pkgsOverlays;
      };
    in
    {
      darwinConfigurations."Lonnets-MacBook-Air" = nix-darwin.lib.darwinSystem {
        modules = [
          # Import our modular darwin configuration
          ./modules/darwin

          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs system; };
              users.lonnetkirisame = import ./modules/home-manager;
            };
          }

          # Flake-specific configuration
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
            nixpkgs.config = pkgsConfig;
            nixpkgs.overlays = pkgsOverlays;
          }
        ];
      };

      checks.${system}.darwin = self.darwinConfigurations."Lonnets-MacBook-Air".system;
      formatter.${system} = pkgs.nixfmt-tree;

      # Development shell for working on the configuration
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil # Nix language server
          nixfmt-tree # Nix tree formatter
          nix-tree # Explore nix dependencies
        ];
      };
    };
}
