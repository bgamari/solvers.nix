{ stdenv, src, metis, scotch, blas, gfortran }:

stdenv.mkDerivation {
  name = "mumps";
  inherit src;

  nativeBuildInputs = [ gfortran ];
  propagatedBuildInputs = [ metis blas ];

  MAKE_INC = ''
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
    CC = gcc
    FC = gfortran
    FL = gfortran
    AR = ar vr 
    RANLIB = ranlib
    LAPACK = -llapack

    INCSEQ = -I$(topdir)/libseq
    LIBSEQ  = $(LAPACK) -L$(topdir)/libseq -lmpiseq

    LIBBLAS = -lblas
    LIBOTHERS = -lpthread

    CDEFS   = -DAdd_

    OPTF    = -O -fopenmp -fallow-argument-mismatch
    OPTL    = -O -fopenmp
    OPTC    = -O -fopenmp
     
    INCS = $(INCSEQ)
    LIBS = $(LIBSEQ)
    LIBSEQNEEDED = libseqneeded
  '';
  enableParallelBuilding = true;
  configurePhase = ''
    echo "$MAKE_INC" > Makefile.inc
  '';
  buildFlags = "all";
  installPhase = ''
    ls -R .
    mkdir -p $out/lib
    cp libseq/libmpiseq.a $out/lib
    cp lib/*.a $out/lib
    cp -r include $out/include
  '';
}

