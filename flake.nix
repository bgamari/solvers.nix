{
  description = "Environment providing the PETSC and various solvers";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.petsc = {
    url = "git+https://gitlab.com/petsc/petsc?tag=v3.22.2";
    flake = false;
  };

  inputs.slepc = {
    url = "git+https://gitlab.com/slepc/slepc?tag=v3.22.2";
    flake = false;
  };

  inputs.sowing = {
    url = "git+https://bitbucket.com/petsc/pkg-sowing/v1.1.26.12";
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
      let
        mkOverlay = mpi: self: super: {
          inherit mpi;

          #blas = self.openblas;

          mumps = self.callPackage ./mumps {
            src = inputs.mumps;
            inherit (self) mpi blas scalapack;
          };

          mumps-serial = self.callPackage ./mumps {
            src = inputs.mumps;
            mpi = null;
            inherit (self) blas scalapack;
          };

          slepc = self.callPackage ./slepc {
            src = inputs.slepc;
            inherit (self) mpi petsc blas;
          };

          sowing = self.callPackage ./sowing {
            src = inputs.sowing;
          };

          #scalapack = super.scalapack.override { inherit mpi; };

          hypre = self.callPackage ./hypre {
            src = inputs.hypre;
            inherit mpi;
          };

          petsc = self.python3Packages.toPythonModule (self.callPackage ./petsc {
            src = inputs.petsc;
            version = "3.22.2";
            inherit (self) mumps sowing mpi blas;
            hypre = if self.mpi == null then null else self.hypre;
            inherit (self.python3Packages) numpy cython;
          });
        };

      in rec {
        lib.mkOverlay = mkOverlay;

        overlays.serial = self: super: mkOverlay null self super;
        overlays.mpich = self: super: mkOverlay self.mpich self super;
        overlays.openmpi = self: super: mkOverlay self.openmpi self super;
        overlays.default = overlays.serial;

        packages = rec {
          openmpi = import nixpkgs { inherit system; overlays = [overlays.openmpi]; };
          mpich   = import nixpkgs { inherit system; overlays = [overlays.mpich]; };
          serial  = import nixpkgs { inherit system; overlays = [overlays.serial]; };
          default = serial;
        };
      }
    );
}

