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

  # 这个文件只做两件事：声明 inputs，把它们接到 darwinSystem 上。
  # 具体配置一律在 modules/ 里，包级别的改写（overlay）也归模块层——
  # nixpkgs.overlays 本来就是模块选项，理由见 README §4.11。
  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      hostName = "Lonnets-MacBook-Air";

      # 全仓库只实例化一次 nixpkgs，靠下面的 `nixpkgs.pkgs` 交给 darwinSystem，
      # home-manager 再通过 useGlobalPkgs 复用同一份。
      # （原来是这里 import 一次、模块里再用 nixpkgs.config/overlays 触发第二次，
      #  等于把整个 nixpkgs 求值两遍。）
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations.${hostName} = nix-darwin.lib.darwinSystem {
        modules = [
          # 系统层
          ./modules/darwin

          # 用户层，作为 nix-darwin 模块集成
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

          # 只有真正属于 flake 层的东西放这里
          {
            nixpkgs.pkgs = pkgs;
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      checks.${system}.darwin = self.darwinConfigurations.${hostName}.system;
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
