class Treecheck < Formula
  desc "Verify files against SHA-256 sidecars to catch silent corruption"
  homepage "https://github.com/prog893/treecheck"
  version "1.0.0"
  license "MIT"

  url "https://github.com/prog893/treecheck.git",
      tag: "v#{version}"

  # Pure shell script: no runtime dependencies beyond bash, find and shasum,
  # all of which ship with macOS. Version must be bumped here manually.

  def install
    bin.install "bin/treecheck"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/treecheck --version")
  end
end
