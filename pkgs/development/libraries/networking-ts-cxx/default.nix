{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "networking-ts-cxx";
  version = "2017-12-10";

  src = fetchFromGitHub {
    owner = "chriskohlhoff";
    repo = "networking-ts-impl";
    rev = "9b50c16ea0dbcc648dd127aabb5e354705b09cfe";
    sha256 = "1d0x058w9iw4h6id0qygf1b9qy6arx1nln73qzya6p9rpbn9mzk8";
  };

  installPhase = ''
    mkdir -p $out/{include,lib/pkgconfig}
    cp -r include $out/
    substituteAll ${./networking_ts.pc.in} $out/lib/pkgconfig/networking_ts.pc
  '';

  meta = {
    description = "Experimental implementation of the C++ Networking Technical Specification";
    homepage = "https://github.com/chriskohlhoff/networking-ts-impl";
    license = stdenv.lib.licenses.boost;
    maintainers = with maintainers; [ bhipple ];
  };
}
