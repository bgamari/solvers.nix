{ stdenv, src }:

stdenv.mkDerivation {
  name = "sowing";
  inherit src;
}
