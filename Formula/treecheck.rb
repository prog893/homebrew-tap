class Treecheck < Formula
  desc "Verify files against SHA-256 sidecars to catch silent corruption"
  homepage "https://github.com/prog893/treecheck"
  # No `version` line: Homebrew scans it from the tag, and declaring both is
  # flagged as redundant. The tag is written out rather than interpolated as
  # "v#{version}", since style autocorrect sorts `url` above `version`, at which
  # point the interpolation resolves to a bare "v" and the clone fails with
  # "Remote branch v not found in upstream origin".
  url "https://github.com/prog893/treecheck.git", tag: "v1.0.0"
  license "MIT"

  head "https://github.com/prog893/treecheck.git", branch: "main"

  # Pure shell. Nothing beyond bash, find and shasum, all of which ship with
  # macOS, so there is nothing to build and nothing to depend on.

  def install
    bin.install "bin/treecheck"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/treecheck --version")

    # Verify the actual job end to end, not just that the binary runs. A file
    # whose contents no longer match its sidecar must be reported and must exit
    # non-zero, since a checker that cannot fail is worse than no checker.
    (testpath/"good.txt").write "intact"
    (testpath/"good.txt.sha256").write "#{Digest::SHA256.hexdigest("intact")}\n"
    assert_match "Verified:        1", shell_output("#{bin}/treecheck #{testpath}")

    # File.write rather than Pathname#write: Homebrew's Pathname refuses to
    # overwrite an existing file, and corrupting this one in place is the point.
    File.write(testpath/"good.txt", "changed")
    output = shell_output("#{bin}/treecheck #{testpath}", 1)
    assert_match "hash mismatch", output
    assert_match "Mismatched:      1", output
  end
end
