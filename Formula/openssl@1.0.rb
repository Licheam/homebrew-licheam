# This formula tracks 1.0.2 branch of OpenSSL, not the 1.1.0 branch. Due to
# significant breaking API changes in 1.1.0 other formulae will be migrated
# across slowly, so core will ship `openssl` & `openssl@1.1` for foreseeable.
class OpensslAT10 < Formula
  desc "SSL/TLS cryptography library"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-1.0.2u.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/openssl-1.0.2u.tar.gz"
  mirror "https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.0.2u.tar.gz"
  sha256 "ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16"

  keg_only :shadowed_by_macos, "macOS provides LibreSSL"

  depends_on "ca-certificates"
  
  on_linux do
    resource "Test::Harness" do
      url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/Test-Harness-3.42.tar.gz"
      mirror "http://cpan.metacpan.org/authors/id/L/LE/LEONT/Test-Harness-3.42.tar.gz"
      sha256 "0fd90d4efea82d6e262e6933759e85d27cbcfa4091b14bf4042ae20bab528e53"
    end

    resource "Test::More" do
      url "https://cpan.metacpan.org/authors/id/E/EX/EXODIST/Test-Simple-1.302175.tar.gz"
      mirror "http://cpan.metacpan.org/authors/id/E/EX/EXODIST/Test-Simple-1.302175.tar.gz"
      sha256 "c8c8f5c51ad6d7a858c3b61b8b658d8e789d3da5d300065df0633875b0075e49"
    end

    resource "ExtUtils::MakeMaker" do
      url "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/ExtUtils-MakeMaker-7.48.tar.gz"
      mirror "http://cpan.metacpan.org/authors/id/B/BI/BINGOS/ExtUtils-MakeMaker-7.48.tar.gz"
      sha256 "94e64a630fc37e80c0ca02480dccfa5f2f4ca4b0dd4eeecc1d65acd321c68289"
    end
  end

  def configure_args
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{openssldir}
      no-ssl3
      no-ssl3-method
      no-zlib
    ]
    on_linux do
      args += (ENV.cflags || "").split
      args += (ENV.cppflags || "").split
      args += (ENV.ldflags || "").split
      args << "enable-md2"
    end
    args
  end

  def install
    if OS.linux?
      ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"

      %w[ExtUtils::MakeMaker Test::Harness Test::More].each do |r|
        resource(r).stage do
          system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
          system "make", "PERL5LIB=#{ENV["PERL5LIB"]}", "CC=#{ENV.cc}"
          system "make", "install"
        end
      end
    end

    # This could interfere with how we expect OpenSSL to build.
    ENV.delete("OPENSSL_LOCAL_CONFIG_DIR")

    # This ensures where Homebrew's Perl is needed the Cellar path isn't
    # hardcoded into OpenSSL's scripts, causing them to break every Perl update.
    # Whilst our env points to opt_bin, by default OpenSSL resolves the symlink.
    ENV["PERL"] = Formula["perl"].opt_bin/"perl" if which("perl") == Formula["perl"].opt_bin/"perl"

    arch_args = []
    if OS.mac?
      arch_args += %W[darwin64-#{Hardware::CPU.arch}-cc enable-ec_nistp_64_gcc_128]
    elsif Hardware::CPU.intel?
      arch_args << (Hardware::CPU.is_64_bit? ? "linux-x86_64" : "linux-elf")
    elsif Hardware::CPU.arm?
      arch_args << (Hardware::CPU.is_64_bit? ? "linux-aarch64" : "linux-armv4")
    end

    system "perl", "./Configure", *(configure_args + arch_args)
    system "make"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
    system "make", "test"
  end

  def openssldir
    etc/"openssl@1.0"
  end

  def post_install
    rm_f openssldir/"cert.pem"
    openssldir.install_symlink Formula["ca-certificates"].pkgetc/"cert.pem"
  end

  def caveats
    <<~EOS
      A CA file has been bootstrapped using certificates from the system
      keychain. To add additional certificates, place .pem files in
        #{openssldir}/certs

      and run
        #{opt_bin}/c_rehash
    EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    assert_predicate pkgetc/"openssl.cnf", :exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system bin/"openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end