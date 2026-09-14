class Txt2srt < Formula
  include Language::Python::Virtualenv

  desc "Align a corrected transcript to its audio and write timed SRT"
  homepage "https://github.com/prog893/txt2srt"
  # No `version` line: Homebrew scans it from the tag, and declaring both is
  # flagged as redundant. The tag is written out rather than interpolated as
  # "v#{version}", since style autocorrect sorts `url` above `version`, at which
  # point the interpolation resolves to a bare "v" and the clone fails.
  url "https://github.com/prog893/txt2srt.git", tag: "v0.4.0"
  license "MIT"

  # A git URL with a tag rather than a release tarball, matching the rest of this
  # tap. It also works while the source repo is private, because Homebrew shells
  # out to git and picks up the user's credentials; a `.tar.gz` from
  # codeload.github.com would 404 without a token.
  head "https://github.com/prog893/txt2srt.git", branch: "main"

  # The default backend is mlx-whisper, so Metal only. macOS 14 is mlx-metal's
  # own floor for its arm64 wheels.
  depends_on arch: :arm64
  depends_on "ffmpeg"
  depends_on macos: :sonoma
  depends_on "python@3.13"

  # ffmpeg does the decoding here, and PyAV is deliberately not among the
  # resources below, though it is a dependency of the project for source
  # installs. PyAV's wheel bundles ad-hoc signed ffmpeg dylibs in `av/.dylibs`,
  # and Homebrew rewrites Mach-O install names in everything it installs, which
  # both breaks those signatures (macOS then kills the process on `import av`
  # with a bare SIGKILL, exit 137, no traceback) and fails outright on the ones
  # whose IDs it cannot rewrite, which fails the whole install. txt2srt.audio
  # falls back to the ffmpeg binary when PyAV is absent, so this build decodes
  # through the formula instead.
  #
  # No torch either, though mlx-whisper declares it. Nothing this CLI calls
  # touches it: the whisper backend uses find_alignment from mlx_whisper.timing,
  # which is pure MLX, and a full alignment has been run in an environment with
  # no torch installed. The mms backend does need torch, and is therefore a
  # source-install extra rather than something this formula can offer: 2.5GB of
  # wheels for an opt-in backend whose model is CC BY-NC anyway.

  resource "anyio" do
    url "https://files.pythonhosted.org/packages/12/b8/4bd346e22b28902df4d651910f5242c28d84e4a5c2435ca5c3f797ed7e2e/anyio-4.15.1-py3-none-any.whl"
    sha256 "6152fdbbf9a77fdec97731721bebf7c4c44f7c29b424b0065826173efc7ed101"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/0b/a7/71ac2cff56fec219ed242bb11b8efb69fcc4bec75db06fb7bfe35de520e6/certifi-2026.7.22-py3-none-any.whl"
    sha256 "62f22742b58a1a33014a2b6b706588a8d7e2a88ae7bd1a6ebe8c992928483775"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/cc/61/d01fc49b8dea277640b55a9e15960dbca9fdc8c9fde18e572d39c59f4019/charset_normalizer-3.5.1-py3-none-any.whl"
    sha256 "6df0ec430f9a831772c23ca5a224cba36517a58a84bb32c32bb59a9fa67c47f6"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/58/50/6c0d534c5f134586a8e1ba4e330569e32f057e33372ae556463212fb4cd3/click-8.5.0-py3-none-any.whl"
    sha256 "255bc9599cf7748b4b1a446ccc735421bd08a2ae529a8b88597d3de5664ee360"
  end

  resource "filelock" do
    url "https://files.pythonhosted.org/packages/cc/06/4f138f618dbea66803291274f228f01daf29f306fe8b96bc30dab765df75/filelock-3.32.6-py3-none-any.whl"
    sha256 "3f16ecd0117feae0dfc147e8c62eb5daeccd8bd800378c3ddf416de9b4feb6b1"
  end

  resource "fsspec" do
    url "https://files.pythonhosted.org/packages/fd/3c/6a2bf344106328fd04963664a60b9bb6496fc25df8e962fcdc1367285fb9/fsspec-2026.7.0-py3-none-any.whl"
    sha256 "b57ddbafedfaef7018c1ecab32aa200a9d7ca26b77965f64e48b70061249d279"
  end

  resource "h11" do
    url "https://files.pythonhosted.org/packages/04/4b/29cac41a4d98d144bf5f6d33995617b185d14b22401f75ca86f384e87ff1/h11-0.16.0-py3-none-any.whl"
    sha256 "63cf8bbe7522de3bf65932fda1d9c2772064ffb3dae62d55932da54b31cb6c86"
  end

  resource "hf-xet" do
    url "https://files.pythonhosted.org/packages/4b/69/55b8dcf636142ae660fec1869fcac14c4da2e8412e14d6eee1523be77e9f/hf_xet-1.6.0-cp38-abi3-macosx_11_0_arm64.whl"
    sha256 "f0906082d9932ae0c0057fa194041c22b4e2cdb46b2592ef3b91f020d62a081a"
  end

  resource "httpcore" do
    url "https://files.pythonhosted.org/packages/7e/f5/f66802a942d491edb555dd61e3a9961140fd64c90bce1eafd741609d334d/httpcore-1.0.9-py3-none-any.whl"
    sha256 "2d400746a40668fc9dec9810239072b40b4484b640a8c38fd654a024c7a1bf55"
  end

  resource "httpx" do
    url "https://files.pythonhosted.org/packages/2a/39/e50c7c3a983047577ee07d2a9e53faf5a69493943ec3f6a384bdc792deb2/httpx-0.28.1-py3-none-any.whl"
    sha256 "d909fcccc110f8c7faf814ca82a9a4d816bc5a6dbfea25d6591d6985b8ba59ad"
  end

  resource "huggingface-hub" do
    url "https://files.pythonhosted.org/packages/c3/7f/3f886a625043b77312b80da2f2bf00b5ecbf5a73061af1aa0259cd258c9d/huggingface_hub-1.31.0-py3-none-any.whl"
    sha256 "9dbb6a503cbe2494ea666695207e7262d410659e09134059deb83e5480864667"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/57/b0/0e52c878c53f245edd3a11020f20979b3f490f245af532c7cae3027754b5/idna-3.19-py3-none-any.whl"
    sha256 "815e7be7a7806d54abb586dc943addc79e8b2ee16915059658cbeff4b1b43bf4"
  end

  resource "llvmlite" do
    url "https://files.pythonhosted.org/packages/7d/85/0b536a3c59f2636d9dd51dda832b6c1d0ffec37608429dedf128664918f1/llvmlite-0.49.0-cp313-cp313-macosx_12_0_arm64.whl"
    sha256 "039fa4054a06f537fb39248d4472284ca96be311a142ec09e69f95630ab469cc"
  end

  resource "mlx" do
    url "https://files.pythonhosted.org/packages/5e/d7/0f9717acf577621ff0899f311eaa16abbfd2ee5a5c2156313f49d080cb5f/mlx-0.32.2-cp313-cp313-macosx_14_0_arm64.whl"
    sha256 "65d3d29b66045ed8dd2d8e437c8770de325843c364f7b7c38cd8ae90a7eec854"
  end

  resource "mlx-whisper" do
    url "https://files.pythonhosted.org/packages/22/b7/a35232812a2ccfffcb7614ba96a91338551a660a0e9815cee668bf5743f0/mlx_whisper-0.4.3-py3-none-any.whl"
    sha256 "6b82b6597a994643a3e5496c7bc229a672e5ca308458455bfe276e76ae024489"
  end

  resource "more-itertools" do
    url "https://files.pythonhosted.org/packages/e8/3d/1087453384dbde46a8c7f9356eead2c58be8a7bf156bca40243377c85715/more_itertools-11.1.0-py3-none-any.whl"
    sha256 "4b65538ae22f6fed0ce4874efd317463a7489796a0939fa66824dd542125a192"
  end

  resource "numba" do
    url "https://files.pythonhosted.org/packages/49/dd/bd9fe772f6c84597b76cac229b3f2890f01a2c64fd70e48ceaae10dd65cb/numba-0.67.0-cp313-cp313-macosx_12_0_arm64.whl"
    sha256 "77e1c7173fee57a0d84e006c7e70346689d6cb3e7db503489bae58646b4eff7b"
  end

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/1b/30/a80189bcc7f5e4258b3fbc3968d909d1756f54d023299ecc39ad6fdb9ef8/numpy-2.4.6-cp313-cp313-macosx_11_0_arm64.whl"
    sha256 "bf162abab1c1a736333192707cef898e735a5ca00f38f27eeedf44b39d9e85eb"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl"
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  # No `depends_on "libyaml"` despite what `brew style` asks for: this is the
  # binary wheel, which bundles what it needs. The same note applies in mlx-asr.rb.
  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/b1/16/95309993f1d3748cd644e02e38b75d50cbc0d9561d21f390a76242ce073f/pyyaml-6.0.3-cp313-cp313-macosx_11_0_arm64.whl"
    sha256 "2283a07e2c21a2aa78d9c4442724ec1eb15f5e42a723b99cb3d822d48f5f7ad1"
  end

  resource "regex" do
    url "https://files.pythonhosted.org/packages/fa/68/241f88458b17c46ed2f80147a60a03b2ada7fb815c23b6bc76c298abb0a5/regex-2026.9.10-cp313-cp313-macosx_11_0_arm64.whl"
    sha256 "d8c668af8f7bdb1d18739c27d30cd9f4b371495a883f75a002fb7a39d740fecd"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/a0/f4/c67b0b3f1b9245e8d266f0f112c500d50e5b4e83cb6f3b71b6528104182a/requests-2.34.2-py3-none-any.whl"
    sha256 "2a0d60c172f83ac6ab31e4554906c0f3b3588d37b5cb939b1c061f4907e278e0"
  end

  resource "scipy" do
    url "https://files.pythonhosted.org/packages/2a/f5/769f36d14922b8071a43e95d24d18b6bdafad10d7f5cf647867e1ac052bc/scipy-1.18.1-cp313-cp313-macosx_12_0_arm64.whl"
    sha256 "e6fb6a55cc0ba97b59a1f288fb86dc6fce8bdfc0fffcbfd015e3a954bf2a2d93"
  end

  resource "tiktoken" do
    url "https://files.pythonhosted.org/packages/ad/5f/6448cfe278c3664ba9ec5b5ac08344341f7dc3d42888476e215a14eda2be/tiktoken-0.14.0-cp313-cp313-macosx_11_0_arm64.whl"
    sha256 "cbe2cc3bba939bcdaf103e03df9d5039d33887080b315624be28ec69059e5f94"
  end

  resource "tqdm" do
    url "https://files.pythonhosted.org/packages/f9/1c/01bfd571a64e7f270e6bab5e33777debe0edc56759233ce84f27dec92d14/tqdm-4.70.0-py3-none-any.whl"
    sha256 "7f585706bfddbdebf89daac705b2dfcc16890130727d3197ca62c732b4310953"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/49/d3/b8441a820a491ddfc024b0b0cf0393375b75ea13866d9c66727e54c2fc80/typing_extensions-4.16.0-py3-none-any.whl"
    sha256 "481caa481374e813c1b176ada14e97f1f67a4539ce9cfeb3f350d78d6370c2e8"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/7f/3e/5db95bcf282c52709639744ca2a8b149baccf648e39c8cc87553df9eae0c/urllib3-2.7.0-py3-none-any.whl"
    sha256 "9fb4c81ebbb1ce9531cce37674bbc6f1360472bc18ca9a553ede278ef7276897"
  end

  resource "mlx-metal" do
    url "https://files.pythonhosted.org/packages/f7/ab/ba1952908c5d2a5070cf1cfbfea0161c4751ea62299e2776819810917483/mlx_metal-0.32.2-py3-none-macosx_14_0_arm64.whl"
    sha256 "3825fff379dbc107dd3413e564a06caeaa24819910ec49c0439e454c06a1b9b8"
  end
  # The wheels are staged during install and unpacked in post_install, and that
  # split is the whole point of it.
  #
  # Homebrew walks the finished keg and rewrites Mach-O install names in every
  # dylib it finds, which for wheels is both unnecessary (they are built to be
  # self-contained) and destructive: it invalidates the ad-hoc code signatures
  # that delocate applied, and macOS then kills the process the moment one of
  # those dylibs is loaded, with SIGKILL and no message. Where it cannot rewrite
  # a file it fails outright, and one failure aborts the linkage step for the
  # whole keg and marks the install as failed. Neither is recoverable from inside
  # `install`: signing the files first makes the rewriting fail, letting it break
  # them and re-signing afterwards leaves the failed-install status behind.
  #
  # So `install` puts nothing in the keg that Homebrew recognises as Mach-O. The
  # wheels are zip archives, and the venv holds only scripts and symlinks until
  # post_install, which runs after the relocation pass, fills it in.
  def install
    virtualenv_create(libexec, "python3.13")

    (libexec/"wheels").mkpath
    resources.each do |r|
      # Homebrew caches downloads as `<sha256>--mlx-0.32.2-cp313-...whl`, and pip
      # parses wheel filenames strictly, rejecting the prefixed name with
      # "Invalid wheel filename (wrong number of parts)". So each wheel is staged
      # back under the name it was published with.
      r.fetch
      cp r.cached_download, libexec/"wheels"/File.basename(r.url)
    end

    # The project itself is pure Python, so install it as a plain copy plus
    # hand-written entry points rather than through pip. Building the wheel would
    # need hatchling, which has no Homebrew formula, and `--no-build-isolation`
    # cannot fetch it inside the sandbox.
    (libexec/"lib/python3.13/site-packages").install "txt2srt"

    # The console scripts from [project.scripts], parsed out of pyproject.toml
    # rather than hardcoded, so that renaming or repointing an entry point there
    # cannot silently leave this formula generating a script for a function that
    # no longer exists.
    entry_points = (buildpath/"pyproject.toml").read
                   .split("[project.scripts]")[1].split("[")[0]
                   .scan(/^\s*([\w-]+)\s*=\s*"([\w.]+):(\w+)"/)
    odie "no [project.scripts] found in pyproject.toml" if entry_points.empty?

    entry_points.each do |script, mod, func|
      (libexec/"bin"/script).write <<~PYTHON
        #!#{libexec}/bin/python
        import sys
        from #{mod} import #{func}
        sys.exit(#{func}())
      PYTHON
      chmod 0755, libexec/"bin"/script
      bin.install_symlink libexec/"bin"/script
    end
  end

  # Wheels only, which Homebrew's own helpers cannot do: `std_pip_args`
  # hard-codes `--no-binary=:all:`, so `venv.pip_install` would try to compile
  # mlx and numba from source, and mlx publishes no sdist at all. `--no-index`
  # forbids pip from reaching the network, so a stale resource list fails loudly
  # instead of being silently patched up from PyPI.
  # `post_install` rather than `post_install_steps`, which `brew style` asks for:
  # the declarative form can copy and mkdir, it cannot run pip.
  def post_install
    python = formula_opt_bin("python@3.13")/"python3.13"
    wheels = (libexec/"wheels").children.select { |f| f.extname == ".whl" }
    odie "no wheels were staged" if wheels.empty?
    system python, "-m", "pip", "--python=#{libexec}/bin/python", "install",
           "--no-deps", "--ignore-installed", "--no-index", *wheels
    rm_r libexec/"wheels"
  end

  def caveats
    <<~EOS
      Whisper weights download on first use (~1.6GB for the default) into
      ~/.cache/huggingface. Nothing is bundled with this formula.

      The `vad` backend needs no weights at all and runs offline.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/txt2srt --version")
    assert_match "forced alignment", shell_output("#{bin}/txt2srt --help").downcase

    # Bad arguments must fail before any weights are fetched.
    assert_match "no such file", shell_output("#{bin}/txt2srt x.wav y.txt 2>&1", 2).downcase
    (testpath/"a.txt").write("A:\nhello\n")
    (testpath/"b.txt").write("B:\nhello\n")
    assert_match "both inputs look like transcripts",
                 shell_output("#{bin}/txt2srt a.txt b.txt 2>&1", 2)

    # The whole tool without the model: parse a transcript, attach synthetic
    # times, cut cues, write an SRT. This is the path every backend shares, and
    # it needs no weights, which a sandboxed `brew test` cannot fetch.
    (testpath/"t.txt").write("話し手 A:
建物は百年前に建てられた

話し手 B:
そうですか
")
    (testpath/"run.py").write <<~PYTHON
      from txt2srt import transcript, cues, outputs
      from txt2srt.backends import Times
      doc = transcript.parse("t.txt")
      t = Times.empty(len(doc.stream), "test")
      for i in range(len(doc.stream)):
          t.set(i, i + 1, i * 0.3, i * 0.3 + 0.3, 0.9)
      t.fill_gaps()
      built = cues.build(doc, t)
      outputs.write_srt(built, "out.srt")
      assert all(c.text in doc.stream for c in built), "cue text must be source text"
    PYTHON
    system libexec/"bin/python", testpath/"run.py"
    assert_match "建物", (testpath/"out.srt").read
    assert_match "建物", (testpath/"out.srt").read

    # Decoding really goes through the ffmpeg binary in this build, since PyAV is
    # deliberately not shipped here, so decode something rather than trust it.
    system formula_opt_bin("ffmpeg")/"ffmpeg", "-nostdin", "-v", "error", "-f", "lavfi",
           "-i", "sine=frequency=440:duration=2", "-ar", "48000", testpath/"tone.wav"
    system libexec/"bin/python", "-c", <<~PYTHON
      from txt2srt.audio import load, SAMPLE_RATE
      a = load("#{testpath}/tone.wav")
      assert abs(len(a) / SAMPLE_RATE - 2.0) < 0.05, len(a)
    PYTHON

    # Metal is reachable, and the whisper backend's alignment entry point is
    # importable. Both are what an upgrade is most likely to break.
    system libexec/"bin/python", "-c", <<~PYTHON
      import mlx.core as mx
      from mlx_whisper.timing import find_alignment
      assert mx.sum(mx.ones((4, 4))).item() == 16.0
      assert find_alignment
    PYTHON
  end
end
