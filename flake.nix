{
  description = "laravel.nvim development and test environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.php p.json ]);
        plugins = {
          "plenary.nvim" = pkgs.vimPlugins.plenary-nvim;
          "nvim-nio" = pkgs.vimPlugins.nvim-nio;
          "nui.nvim" = pkgs.vimPlugins.nui-nvim;
          "nvim-treesitter" = treesitter;
          "telescope.nvim" = pkgs.vimPlugins.telescope-nvim;
          "fzf-lua" = pkgs.vimPlugins.fzf-lua;
          "snacks.nvim" = pkgs.vimPlugins.snacks-nvim;
          "nvim-cmp" = pkgs.vimPlugins.nvim-cmp;
          "blink.cmp" = pkgs.vimPlugins.blink-cmp;
        };
        linkPlugins = pkgs.lib.concatStringsSep "\n" (
          pkgs.lib.mapAttrsToList
            (name: path: ''ln -sfn ${path} "$deps/${name}"'')
            plugins
        );
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            neovim
            git
            ripgrep
            jq
            gnumake
            stylua
            luajitPackages.luacheck
            selene
            php
            phpPackages.composer
          ];

          shellHook = ''
            root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
            deps="$root/.tests/deps"
            mkdir -p "$deps"
            ${linkPlugins}
            export LARAVEL_TEST_DEPS="$deps"
            export LARAVEL_TS_PARSERS="${pkgs.lib.concatStringsSep ":" treesitter.passthru.dependencies}"
            echo "laravel.nvim test deps: $LARAVEL_TEST_DEPS"
          '';
        };
      });
}
