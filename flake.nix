{
  description = "Environment providing the PETSC and various solvers";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.petsc = {
    url = "git+https://gitlab.com/petsc/petsc?tag=v3.18.3";
    flake = false;
  };

  inputs.slepc = {
    url = "git+https://gitlab.com/slepc/slepc?tag=v3.18.1";
    flake = false;
  };

  inputs.sowing = {
    url = "git+https://bitbucket.com/petsc/pkg-sowing/v1.1.26-p6";
    flake = false;
  };

  inputs.hypre = {
    url = "github:hypre-space/hypre";
    flake = false;
  };

  inputs.mumps = {
    url = "git+https://bitbucket.com/petsc/pkg-mumps/v5.4.1-p1";
    flake = false;
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = 
          let
            mkPackages = mpi: rec {
              inherit mpi;

              blas = pkgs.openblasCompat;

              mumps = pkgs.callPackage ./mumps {
                src = inputs.mumps;
                inherit mpi blas scalapack;
              };

              mumps-serial = pkgs.callPackage ./mumps {
                src = inputs.mumps;
                mpi = null;
                inherit blas scalapack;
              };

              slepc = pkgs.callPackage ./slepc {
                src = inputs.slepc;
                inherit mpi petsc blas;
              };

              sowing = pkgs.callPackage ./sowing {
                src = inputs.sowing;
              };

              scalapack = pkgs.scalapack.override { inherit mpi; };

              hypre = pkgs.callPackage ./hypre {
                src = inputs.hypre;
                inherit mpi;
              };

              petsc = pkgs.python3Packages.toPythonModule (pkgs.callPackage ./petsc {
                src = inputs.petsc;
                version = "3.18.3";
                inherit mumps sowing mpi blas;
                hypre = if mpi == null then null else hypre;
                inherit (pkgs.python3Packages) numpy cython;
              });
            };
          in rec {
            openmpi = mkPackages pkgs.openmpi;
            mpich = mkPackages pkgs.mpich;
            serial = mkPackages null;
            default = serial;
          };
      }
    );
}

