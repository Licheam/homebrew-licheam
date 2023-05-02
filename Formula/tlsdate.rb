class Tlsdate < Formula
  homepage 'https://www.github.com/ioerror/tlsdate/'
  url 'https://github.com/ioerror/tlsdate/archive/refs/tags/tlsdate-0.0.13.tar.gz'
  # This hash will never be correct until we put a tagged version into master
  # update accordingly until we do a proper release that supports OS X
  sha256 '90efdff87504b5159cb6a3eefa9ddd43723c073d49c4b3febba9e48fc1292bf9'
  version '0.0.13'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build
  depends_on 'libevent' => :build
  depends_on 'pkg-config' => :build
  depends_on 'licheam/licheam/openssl@1.0' => :build

  patch do
    url "https://github.com/Licheam/tlsdate/commit/831923d36027079f9c90cb9f338b43d7004c188a.patch?full_index=1"
    sha256 "33c400434dbadf66df5df7e380fd72493f36a861946b2d41bf652ff0edfc98e2"
  end

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