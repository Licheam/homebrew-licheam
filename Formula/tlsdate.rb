class Tlsdate < Formula
  homepage 'https://www.github.com/ioerror/tlsdate/'
  url 'https://github.com/ioerror/tlsdate/archive/refs/tags/tlsdate-0.0.13.tar.gz'
  # This hash will never be correct until we put a tagged version into master
  # update accordingly until we do a proper release that supports OS X
  sha256 '90efdff87504b5159cb6a3eefa9ddd43723c073d49c4b3febba9e48fc1292bf9'
  version '0.0.13'

  # depends_on 'autoconf' => :build
  # depends_on 'automake' => :build
  # depends_on 'libtool' => :build
  # depends_on 'libevent' => :build
  # depends_on 'pkg-config' => :build
  # depends_on 'openssl@1.1'

  patch do
    url "https://github.com/ioerror/tlsdate/compare/tlsdate-0.0.13...akiernan:tlsdate:master.patch?full_index=1"
    sha256 "ed9fef28aec4ba4e21574258be391958c5c2f3b088a529df6f7e45837c6db5d4"
  end

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end

  test do
    system "tlsdate -v -n"
  end
end