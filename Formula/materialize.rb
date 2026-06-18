class Materialize < Formula
  desc "Force-download cloud-only files via NSFileCoordinator"
  homepage "https://github.com/prog893/materialize"
  url "https://github.com/prog893/materialize.git",
      tag: "v1.0.0",
      revision: "7011248c7f8ec8e7e4e7e7e7e7e7e7e7e7e7e7e7"
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