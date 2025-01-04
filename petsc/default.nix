{ stdenv, lib,
  src, version,
  pkg-config, gfortran,
  blas, liblapack, mpi,
  python3, numpy, cython, python3Packages,
  metis, mumps, scotch, scalapack, sowing, hypre
}:

let
  mpiSupport = mpi != null;
  mumpsSupport = mumps != null;
  hypreSupport = hypre != null;
in
assert hypreSupport -> mpiSupport;
stdenv.mkDerivation rec {
  name = "petsc";
  inherit version src;

  nativeBuildInputs = [
    pkg-config python3 gfortran cython python3Packages.setuptools
  ] ++ lib.optional mpiSupport mpi;

  buildInputs = [
    blas liblapack python3 mumps scalapack sowing
    numpy
  ];

  enableParallelBuilding = true;

  preConfigure = ''
    export FC="${gfortran}/bin/gfortran" F77="${gfortran}/bin/gfortran"
    patchShebangs ./lib/petsc/bin
    configureFlagsArray=(
      $configureFlagsArray
      ${if !mpiSupport then ''
        "--with-mpi=0"
      '' else ''
        "--CC=mpicc"
        "--with-cxx=mpicxx"
        "--with-fc=mpif90"
        "--with-mpi=1"
      ''}
    )
  '';

  configureScript = "python ./configure";

  configureFlags =
    lib.optionals mumpsSupport [
      (if mpiSupport then "--with-mumps-parallel" else "--with-mumps-serial")
      "--with-mumps-dir=${mumps}"
    ] ++ lib.optionals (mumpsSupport && mpiSupport) [
      "--with-scalapack"
      "--with-scalapack-dir=${scalapack}"
    ] ++ lib.optionals hypreSupport [
      "--with-hypre=1"
      "--with-hypre-dir=${hypre}"
    ] ++ [
    "--with-fc=gfortran"
    "--with-openmp"

    #"--with-ptscotch"
    #"--with-ptscotch-dir=${scotch}"

    "--with-metis"
    "--with-metis-dir=${metis}"

    "--with-petsc4py=1"

    "--with-blas=1"
    "--with-blas-lib=[${blas}/lib/libblas.a,${gfortran.cc.lib}/lib/libgfortran.a]"

    "--with-lapack=1"
    "--with-lapack-lib=[${liblapack}/lib/liblapack.a,${gfortran.cc.lib}/lib/libgfortran.a]"

    "--with-shared-libraries=1"
    "--with-scalar-type=real"
    "--with-debugging=0"

    "COPTFLAGS=-O3"
    "CXXOPTFLAGS=-O3"
    "FOPTFLAGS=-O3"
  ];

  # Fix up Python bindings
  postInstall = ''
     mkdir -p $out/${python3.sitePackages}
     ln -s $out/lib/petsc4py $out/${python3.sitePackages}/petsc4py
     ln -s $out/lib/petsc4py-${version}-py${python3.pythonVersion}.egg-info $out/${python3.sitePackages}/
  '';
}

