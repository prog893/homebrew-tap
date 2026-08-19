class Utfcopy < Formula
  desc "Pbcopy/pbpaste replacement that works with emoji and CJK without locale tweaks"
  homepage "https://github.com/prog893/utfcopy"
  # No `version` line: Homebrew scans it from the tag, and declaring both is
  # flagged as redundant. The tag is written out rather than interpolated as
  # "v#{version}", since style autocorrect sorts `url` above `version`, at which
  # point the interpolation resolves to a bare "v" and the clone fails with
  # "Remote branch v not found in upstream origin".
  url "https://github.com/prog893/utfcopy.git", tag: "v1.0.0"
  license "MIT"

  head "https://github.com/prog893/utfcopy.git", branch: "main"

  # AppKit only, so macOS-only, but it builds on both architectures.
  #
  # Deliberately not `depends_on xcode:`. That requirement demands a full
  # Xcode.app and fails with "Installing just the Command Line Tools is not
  # sufficient", yet one Swift file against AppKit needs nothing beyond the
  # swiftc and SDK that the Command Line Tools already ship.
  depends_on :macos

  def install
    # --disable-sandbox because SwiftPM sandboxes its own manifest compile, and
    # nesting that inside Homebrew's build sandbox fails with
    # "sandbox-exec: sandbox_apply: Operation not permitted", reported as
    # "Invalid manifest". Homebrew's sandbox still applies to the build.
    system "swift", "build", "-c", "release", "--disable-sandbox"

    # Two executable targets from one source file: utfpaste is the same code
    # compiled with -D PASTE_MODE. They are separate binaries rather than a
    # symlink pair, so neither depends on argv[0] and renaming one cannot change
    # what it does.
    bin.install ".build/release/utfcopy", ".build/release/utfpaste"
  end

  test do
    # Round-trip through the real pasteboard, which exercises both commands and
    # the argv[0] dispatch that the symlink above depends on. `brew test` runs
    # in a user session, so NSPasteboard is reachable.
    #
    # The payload is deliberately non-ASCII. This is the whole point of the
    # package: under `brew test` the locale is often unset, which is exactly the
    # case where pbcopy would store MacRoman and corrupt these bytes.
    unicode = "Hello ✅ 日本語 🎉"
    pipe_output(bin/"utfcopy", unicode, 0)
    assert_equal unicode, shell_output(bin/"utfpaste")

    # utfpaste adds no trailing newline, so a round trip is byte-exact and
    # command substitution does not need stripping.
    pipe_output(bin/"utfcopy", "no-newline", 0)
    assert_equal "no-newline", shell_output(bin/"utfpaste")

    # Invalid UTF-8 is refused rather than copied lossily, and must not disturb
    # what is already on the pasteboard. \xC3 opens a two-byte sequence that
    # "(" cannot continue. The stderr redirection needs a string rather than a
    # Pathname, since it is a shell fragment and not just the binary.
    pipe_output(bin/"utfcopy", "sentinel", 0)
    pipe_output("#{bin}/utfcopy 2>/dev/null", "\xC3\x28", 1)
    assert_equal "sentinel", shell_output(bin/"utfpaste")
  end
end
