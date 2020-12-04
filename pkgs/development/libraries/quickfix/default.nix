{ stdenv, fetchFromGitHub, autoconf, automake, libtool }:

let
  name = "quickfix";
  version = "1.15.1";
in stdenv.mkDerivation rec {
  inherit name;

  nativeBuildInputs = [ autoconf automake libtool ];

  src = fetchFromGitHub {
    owner = "${name}";
    repo = "${name}";
    rev =  "v${version}";
    sha256 = "1fgpwgvyw992mbiawgza34427aakn5zrik3sjld0i924a9d17qwg";
  };

  # This ugly mess is to not build or link the unittests, which do not compile with c++17
  preConfigure = ''
     substituteInPlace ./src/Makefile.am --replace 'LDFLAGS =-L../UnitTest++ -lUnitTest++' ' '
     substituteInPlace ./src/Makefile.am --replace 'noinst_PROGRAMS = at ut pt' 'noinst_PROGRAMS = at pt'
     substituteInPlace ./src/Makefile.am --replace 'ut_SOURCES = ut.cpp' ' '
     substituteInPlace ./src/Makefile.am --replace 'ut_LDADD = C++/test/libquickfixcpptest.la C++/libquickfix.la' ' '
     substituteInPlace ./src/Makefile.am --replace 'rm -f ../test/ut ' 'rm -rf '
     substituteInPlace ./src/Makefile.am --replace 'ln -s ../src/ut ../test/ut' 'true '
     substituteInPlace ./src/Makefile.am --replace 'ln -s ../src/.libs/ut ../test/ut_debug' 'true '
     substituteInPlace ./configure.ac --replace 'build_no_unit_test = no' 'build_no_unit_test = yes'
     substituteInPlace ./configure.ac --replace $'    examples/ordermatch/Makefile\n' ""
     substituteInPlace ./configure.ac --replace $'    examples/ordermatch/test/Makefile\n' ""
     substituteInPlace ./examples/Makefile.am  --replace 'ordermatch' ' '
     ./bootstrap
  '';

  # More hacking out of the unittests
  preBuild = ''
    substituteInPlace Makefile --replace 'UnitTest++' ' '
  '';

  configureFlags = [
    "--enable-shared=yes"
    "--enable-static=yes"
  ];

  # This patch is from https://github.com/quickfix/quickfix/commit/a46708090444826c5f46a5dbf2ba4b069b413c58
  # which fixes all files in src, but not in UnitTests++
  patches = [ ./cpp17-fix-a46708.patch ];

  meta = with stdenv.lib; {
    description = "QuickFIX C++ Fix Engine Library";
    homepage = "http://www.quickfixengine.org";
    license = stdenv.lib.licenses.free; # similar to BSD 4-clause
    maintainers = with maintainers; [ bhipple ];
  };
}
