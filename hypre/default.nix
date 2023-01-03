{
  stdenv, src,
  cmake,
  mpi
}:

stdenv.mkDerivation {
  name = "hypre";
  inherit src;
  sourceRoot = "source/src";
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    mpi
  ];
}


