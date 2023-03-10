{ stdenv, src, python3, gfortran, git, mpi,
  petsc, blas, liblapack }:

stdenv.mkDerivation {
  name = "slepc";
  nativeBuildInputs = [ python3 gfortran git ];
  buildInputs = [ mpi petsc blas liblapack ];
  inherit src;
  PETSC_DIR = petsc;
  preConfigure = ''
    patchShebangs .
  '';
  configurePhase = ''
    export SLEPC_DIR="`pwd`"
    python3 ./config/configure.py --prefix=$out
  '';
}
