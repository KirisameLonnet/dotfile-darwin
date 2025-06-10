{
  description = "Modern modular macOS configuration with nix-darwin + home-manager + yabai";  # SketchyBar removed

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  let
    system = "aarch64-darwin";
    
    # Custom packages configuration
    pkgsConfig = {
      allowUnfree = true;
      overlays = [
        # Custom overlay for window management tools
        (final: prev: {
          # Use the latest yabai from nixpkgs
          yabai-latest = prev.yabai;
          
          # SketchyBar - DISABLED
          # In the meantime, we'll use homebrew for SketchyBar
          # sketchybar-placeholder = prev.writeShellScriptBin "sketchybar" ''
          #   echo "SketchyBar managed by homebrew"
          # '';
        })
      ];
    };

    pkgs = import nixpkgs {
      inherit system;
      config = pkgsConfig;
    };
  in
  {
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      inherit system;
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
            users.lonnetkirisame = import ./modules/home-manager;
          };
        }
        
        # Basic system configuration
        ({ config, pkgs, ... }: {
          # Users
          users.users.lonnetkirisame = {
            name = "lonnetkirisame";
            home = "/Users/lonnetkirisame";
          };

          # Nix configuration
          nix.settings.experimental-features = "nix-command flakes";
          # services.nix-daemon.enable = true; # Removed - managed automatically
          programs.zsh.enable = true;

          # System version
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 5;
          nixpkgs.hostPlatform = system;
          nixpkgs.config = pkgsConfig;
        })
      ];
    };

    # Development shell for working on the configuration
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nil # Nix language server
        nixpkgs-fmt # Nix formatter
        nix-tree # Explore nix dependencies
      ];
    };
  };
}
