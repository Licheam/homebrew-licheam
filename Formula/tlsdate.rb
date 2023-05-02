class Tlsdate < Formula
  homepage 'https://www.github.com/ioerror/tlsdate/'
  url 'https://github.com/ioerror/tlsdate/archive/refs/tags/tlsdate-0.0.13.tar.gz'
  # This hash will never be correct until we put a tagged version into master
  # update accordingly until we do a proper release that supports OS X
  sha256 '61aaee6e109484965d38f9ffd08f0ea4cbe967ba61027bc29d7bbdc925d21417'
  version 'db811efad1d655e5aad763d0871aa4e97fcbfcfc'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build
  depends_on 'libevent' => :build
  depends_on 'pkg-config' => :build
  depends_on 'openssl@1.1'

  def install
    system "./autogen.sh"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end

  test do
    system "tlsdate -v -n"
  end
end