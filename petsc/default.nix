{ stdenv, src,
  pkgconfig, gfortran, blas, liblapack, python, mpi,
  metis, mumps, scotch, scalapack, sowing, hypre
}:

stdenv.mkDerivation rec {
  name = "petsc";
  inherit src;

  nativeBuildInputs = [
    pkgconfig gfortran python
  ];
  buildInputs = [
    blas liblapack python mumps scalapack sowing mpi
  ];
  enableParallelBuilding = true;

  patches = [ ./fix-petsc-configure.patch ];

  preConfigure = ''
    patchShebangs .
    configureFlagsArray=(
      $configureFlagsArray
      --prefix=$out
    )
  '';

  PETSC_ARCH = "arch-linux2-c-opt";

  configureFlags = [
    "--with-fc=gfortran"
    "--with-openmp"
    "--with-mpi=0"
    #"--with-ptscotch"
    #"--with-ptscotch-dir=${scotch}"
    "--with-metis"
    "--with-metis-dir=${metis}"
    "--with-mumps-serial"
    "--with-mumps-dir=${mumps}"
    #"--with-scalapack"
    "--with-shared-libraries=1"
    "--with-scalar-type=real"
    "--with-debugging=0"
    "--with-blas-lib=[${blas}/lib/libblas.a,${gfortran.cc.lib}/lib/libgfortran.a]"
    "--with-lapack-lib=[${liblapack}/lib/liblapack.a,${gfortran.cc.lib}/lib/libgfortran.a]"
    "COPTFLAGS=-O3"
    "CXXOPTFLAGS=-O3"
    "FOPTFLAGS=-O3"
  ];

  configurePhase = ''
    python configure --prefix=$out $configureFlags
  '';

  installPhase = ''
    make install
  '';
}

