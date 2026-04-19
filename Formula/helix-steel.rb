class HelixSteel < Formula
  desc "Helix fork with Steel event system support"
  homepage "https://github.com/mattwparas/helix"
  license "MPL-2.0"
  head "https://github.com/mattwparas/helix.git", branch: "steel-event-system"

  depends_on "rust" => :build

  conflicts_with "helix", because: "both install the `hx` binary"
  conflicts_with "evil-helix", because: "both install the `hx` binary"
  conflicts_with "hex", because: "both install the `hx` binary"

  def install
    ENV["HELIX_DEFAULT_RUNTIME"] = libexec/"runtime"
    system "cargo", "install", "-vv", "--features", "steel,git",
           *std_cargo_args(path: "helix-term")
    rm_r "runtime/grammars/sources/"
    libexec.install "runtime"

    bash_completion.install "contrib/completion/hx.bash" => "hx"
    fish_completion.install "contrib/completion/hx.fish"
    zsh_completion.install "contrib/completion/hx.zsh" => "_hx"
  end

  test do
    assert_match "helix", shell_output("#{bin}/hx --version").downcase
  end
end
