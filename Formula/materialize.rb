class Materialize < Formula
  desc "Force-download cloud-only files via NSFileCoordinator"
  homepage "https://github.com/prog893/materialize"
  url "https://github.com/prog893/materialize.git",
      tag:      "v1.0.0",
      revision: "701124811f353f0ea8d1dc98e9b48403a6e8f443"
  version "1.0.0"
  license "MIT"

  depends_on xcode: ["15.0", :build]

  def install
    system "swift", "build", "-c", "release"
    bin.install ".build/release/materialize"
  end

  test do
    (testpath/"test.txt").write("test")
    system bin/"materialize", testpath/"test.txt"
  end
end