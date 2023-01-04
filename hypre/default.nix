{
  stdenv, src,
  cmake,
  mpi
}:

assert mpi != null;
stdenv.mkDerivation {
  name = "hypre";
  inherit src;
  sourceRoot = "source/src";
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    mpi
  ];
}


