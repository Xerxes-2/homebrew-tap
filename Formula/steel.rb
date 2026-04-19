class Steel < Formula
  desc "Embedded scheme interpreter in Rust"
  homepage "https://github.com/mattwparas/steel"
  url "https://github.com/mattwparas/steel/releases/download/v0.8.2/steel-source.tar.gz"
  sha256 "3ba6a00631cf0dd32ff117003b57ee131c7ed423a8cc19438ea6d2806c1375b3"
  license any_of: ["Apache-2.0", "MIT"]

  depends_on "rust" => :build

  ghrel = "https://github.com/mattwparas/steel/releases/download/v0.8.2"

  sha256s = {
    macos_arm:   {
      "steel-interpreter"     => "5fe571883a6fa1989734bca6ce17dcdc570d981b6f5ff08c443157d1da76d364",
      "steel-forge"           => "b10c0e3b41add66b3ba7c9cc3e6ce5c7927ead2240c4fc67150c552ade86a39e",
      "steel-language-server" => "7d404cfb3ef136b85ef055d82871be49f503fd7917a4d3fb594564499039c7a7",
      "cargo-steel-lib"       => "754974560d186326e5b6462e263316b93b4027f908c69f7d7e916a5f9c5861f0",
    },
    linux_arm:   {
      "steel-interpreter"     => "151f9380b0bcdee0314dc884a8fa461da099785d201b503c2657a42c44d22ac8",
      "steel-forge"           => "21f6c903b5325e9953af9e5c05c5bfe4152ccc10b28bcc2c8c726c1fd0bb9654",
      "steel-language-server" => "a09f8ce8fad3e9552d0c461c23307652681e6e7776f40c40a42a999191c68e8a",
      "cargo-steel-lib"       => "bf4be5736e69ff9cdd39a0db9b4d35a500ffe4d07fb3618024f99f27979f9a69",
    },
    linux_intel: {
      "steel-interpreter"     => "d0334d14168df4b88bb16bd4dbdfe03ab4bac147122f1be0c2ec5f083bf726fe",
      "steel-forge"           => "11bafc23cf8a93655fbfc9a06d7cf0015173ad8b40abd999b26d496e27cadd70",
      "steel-language-server" => "d6cbc621cb76d132f91236acbba41868a0d84e95aaa412c0bd07e7ca0460810a",
      "cargo-steel-lib"       => "44ca1d46e6978852db5e72b8082b198cc3e3a2c1fe5f09928d1d2d0542a9c24f",
    },
  }

  %w[steel-interpreter steel-forge steel-language-server cargo-steel-lib].each do |pkg|
    resource pkg do
      on_macos do
        on_arm do
          url "#{ghrel}/#{pkg}-aarch64-apple-darwin.tar.xz"
          sha256 sha256s[:macos_arm][pkg]
        end
      end
      on_linux do
        on_arm do
          url "#{ghrel}/#{pkg}-aarch64-unknown-linux-gnu.tar.xz"
          sha256 sha256s[:linux_arm][pkg]
        end
        on_intel do
          url "#{ghrel}/#{pkg}-x86_64-unknown-linux-gnu.tar.xz"
          sha256 sha256s[:linux_intel][pkg]
        end
      end
    end
  end

  def install
    binaries = {
      "steel-interpreter"     => "steel",
      "steel-forge"           => "forge",
      "steel-language-server" => "steel-language-server",
      "cargo-steel-lib"       => "cargo-steel-lib",
    }

    binaries.each do |res_name, bin_name|
      resource(res_name).stage do
        dirs = Dir.glob("#{res_name}-*")
        if dirs.any?
          bin.install "#{dirs.first}/#{bin_name}"
        else
          bin.install bin_name
        end
      end
    end

    # Install cogs from source
    cd "source" do
      ENV["STEEL_HOME"] = share/"steel"
      system bin/"steel", "cogs/install.scm", "cogs"
    end

    generate_completions_from_executable(bin/"steel", "completions")
  end

  def caveats
    <<~EOS
      To use Steel cogs, set the following environment variable:
        export STEEL_SEARCH_PATHS=#{share}/steel/cogs
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/steel --version")
  end
end
