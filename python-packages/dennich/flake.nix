{
  description = "dennich - Personal Python utilities with todo management and Anki integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    uv2nix,
    pyproject-nix,
    pyproject-build-systems,
    ...
  }: let
    inherit (nixpkgs) lib;

    # Load the uv workspace from the current directory
    workspace = uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};

    # Create package overlay from workspace
    overlay = workspace.mkPyprojectOverlay {
      # Prefer binary wheels for better compatibility
      sourcePreference = "wheel";
    };

    # Build fixups overlay for packages that need special handling
    pyprojectOverrides = final: prev: {
      # Anki might need special handling for Qt dependencies
      # Add overrides here if needed during build
    };

    # Support both x86_64-linux and aarch64-linux
    forAllSystems = f:
      nixpkgs.lib.genAttrs
      ["x86_64-linux" "aarch64-linux"]
      (system: f nixpkgs.legacyPackages.${system});

    # Create Python package set for each system
    mkPythonSet = pkgs: python:
      (pkgs.callPackage pyproject-nix.build.packages {
        inherit python;
      }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
          pyprojectOverrides
        ]
      );
  in {
    # Package the virtual environment with all dependencies
    packages = forAllSystems (pkgs: {
      default = (mkPythonSet pkgs pkgs.python313).mkVirtualEnv "dennich-env" workspace.deps.default;
    });

    # Make the CLI tools runnable with `nix run`
    apps = forAllSystems (pkgs: {
      default = {
        type = "app";
        program = "${self.packages.${pkgs.system}.default}/bin/dennich-todo";
      };

      todo = {
        type = "app";
        program = "${self.packages.${pkgs.system}.default}/bin/dennich-todo";
      };

      danki = {
        type = "app";
        program = "${self.packages.${pkgs.system}.default}/bin/dennich-danki";
      };

      pomodoro = {
        type = "app";
        program = "${self.packages.${pkgs.system}.default}/bin/dennich-pomodoro";
      };
    });

    # Development shells
    devShells = forAllSystems (pkgs: let
      python = pkgs.python313;
    in {
      # Impure shell using uv to manage virtualenv
      default = pkgs.mkShell {
        packages = [
          python
          pkgs.uv
          pkgs.ruff
          pkgs.mypy
        ];

        env =
          {
            UV_PYTHON_DOWNLOADS = "never";
            UV_PYTHON = python.interpreter;
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
          };

        shellHook = ''
          unset PYTHONPATH
          echo "dennich development shell"
          echo "Available commands:"
          echo "  uv sync          - Sync dependencies"
          echo "  uv run pytest    - Run tests"
          echo "  uv run mypy      - Run type checking"
        '';
      };

      # Pure nix-managed development environment with editable installs
      pure = let
        editableOverlay = workspace.mkEditablePyprojectOverlay {
          root = "$REPO_ROOT";
          members = ["dennich"];
        };

        editablePythonSet = (mkPythonSet pkgs python).overrideScope (
          lib.composeManyExtensions [
            editableOverlay

            (final: prev: {
              dennich = prev.dennich.overrideAttrs (old: {
                # Filter sources for editable build
                src = lib.fileset.toSource {
                  root = old.src;
                  fileset = lib.fileset.unions [
                    (old.src + "/pyproject.toml")
                    (old.src + "/README.md")
                    (old.src + "/src")
                    (old.src + "/tests")
                    (old.src + "/alembic.ini")
                  ];
                };

                # Add editables dependency for uv-build backend
                nativeBuildInputs =
                  old.nativeBuildInputs
                  ++ final.resolveBuildSystem {
                    editables = [];
                  };
              });
            })
          ]
        );

        virtualenv = editablePythonSet.mkVirtualEnv "dennich-dev-env" workspace.deps.all;
      in
        pkgs.mkShell {
          packages = [
            virtualenv
            pkgs.uv
            pkgs.ruff
            pkgs.mypy
          ];

          env = {
            UV_NO_SYNC = "1";
            UV_PYTHON = python.interpreter;
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            unset PYTHONPATH
            export REPO_ROOT=$(pwd)
            echo "dennich pure development shell (editable mode)"
            echo "Python packages installed in editable mode at: $REPO_ROOT"
          '';
        };
    });
  };
}
