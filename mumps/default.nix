{
  stdenv, lib, src, gfortran,
  mpi, metis, scotch, blas, scalapack
}:

let
  mpiSupport = mpi != null;
in
stdenv.mkDerivation {
  name = "mumps";
  inherit src;

  nativeBuildInputs = [ gfortran ];
  propagatedBuildInputs =
    [ metis blas ] ++
    lib.optionals mpiSupport [
      mpi scalapack
    ];

  MAKE_INC = 
    (if !mpiSupport then ''
      CC = gcc
      FC = gfortran
      FL = gfortran
     '' else ''
      CC = mpicc
      FC = mpif90
      FL = mpif90
     '') + ''
    LPORDDIR = $(topdir)/PORD/lib/
    IPORD    = -I$(topdir)/PORD/include/
    LPORD    = -L$(LPORDDIR) -lpord

    LMETISDIR = ${metis}/lib
    IMETIS    = -I${metis}/include/metis
    LMETIS    = -lmetis

    ORDERINGSF = -Dmetis -Dpord
    ORDERINGSC  = $(ORDERINGSF)

    LORDERINGS = $(LMETIS) $(LPORD) $(LSCOTCH)
    IORDERINGSF = $(ISCOTCH)
    IORDERINGSC = $(IMETIS) $(IPORD) $(ISCOTCH)

    PLAT    =
    LIBEXT  = .a
    OUTC    = -o 
    OUTF    = -o 
    RM = /bin/rm -f
    AR = ar vr 
    RANLIB = ranlib
    LAPACK = -llapack
    SCALAP  = -lscalapack

    LIBPAR = $(SCALAP) $(LAPACK)

    INCSEQ = -I$(topdir)/libseq
    LIBSEQ  = $(LAPACK) -L$(topdir)/libseq -lmpiseq

    LIBBLAS = -lblas
    LIBOTHERS = -lpthread

    CDEFS   = -DAdd_

    OPTF    = -O -fopenmp -fallow-argument-mismatch
    OPTL    = -O -fopenmp
    OPTC    = -O -fopenmp
     
  '' +
  (if !mpiSupport then ''
     LIBSEQNEEDED = libseqneeded
     INCS = $(INCSEQ)
     LIBS = $(LIBSEQ)
   '' else ''
     LIBSEQNEEDED =
     INCS = $(INCPAR)
     LIBS = $(LIBPAR)
   '') ;
  enableParallelBuilding = true;
  configurePhase = ''
    echo "$MAKE_INC" > Makefile.inc
  '';
  buildFlags = "all";
  installPhase = ''
    ls -R .
    mkdir -p $out/lib
    cp lib/*.a $out/lib
    cp -r include $out/include
  '' + lib.optionalString (!mpiSupport) ''
    cp libseq/libmpiseq.a $out/lib
  '';
}

