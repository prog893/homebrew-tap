# homebrew-tap Development Guide

This repo is the single Homebrew tap for all `prog893` CLI tools.
Users install via: `brew tap prog893/tap` → `brew install prog893/tap/<formula>`

---

## Tap Conventions

- One `.rb` file per tool in `Formula/`, named `<tool-name>.rb`
- Formula class name: PascalCase of the tool name (e.g. `StaqanYt` for `staqan-yt`)
- All formulas must have: `desc`, `homepage`, `version`, `url`, `license`, `depends_on`, `install`, `test`
- Source-based installs from GitHub (git tag URL) are preferred for private repos

---

## Onboarding a New Tool

### 1. Create `Formula/<tool-name>.rb`

Minimal template:

```ruby
class ToolName < Formula
  desc "Short one-line description"
  homepage "https://github.com/prog893/<tool-name>"
  version "1.0.0"
  license "MIT"

  url "https://github.com/prog893/<tool-name>.git",
      tag: "v#{version}"

  depends_on "oven-sh/bun/bun"  # or other runtime

  def install
    bun = Formula["bun"].opt_bin/"bun"
    system bun, "install"
    system bun, "build", "./bin/<tool-name>.ts", "--compile", "--outfile", "<tool-name>"
    bin.install "<tool-name>"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/<tool-name> --version")
  end
end
```

### 2. Add a row to the table in `README.md`

```markdown
| tool-name | Short description |
```

### 3. Update the tool's release scripts to push formula updates here

The tool repo's `postversion` script should clone/pull this repo, update the formula version, commit, and push.

---

## Version Update Process

Tool repos are responsible for updating their formula version here. The automated flow:

1. Tool repo bumps its version (`npm version patch`)
2. `scripts/version.ts` writes the updated `.rb` to a local clone of this repo
3. `scripts/postversion.ts` commits `"<tool> X.Y.Z"` and pushes to this repo

Human review is not required for version-only commits (version string change only).

---

## Shell Script Tools

For standalone shell scripts (no npm/bun project):

```ruby
url "https://raw.githubusercontent.com/prog893/<tool>/v#{version}/<tool>.sh"
sha256 "<sha256 of the file>"

def install
  bin.install "<tool>.sh" => "<tool>"
end
```

Run `shasum -a 256 <file>` to get the sha256.

---

## Python Tools

Pin Python version and use virtualenv:

```ruby
depends_on "python@3.12"
uses_from_macos "libffi"

resource "requests" do
  url "https://files.pythonhosted.org/..."
  sha256 "..."
end

def install
  virtualenv_install_with_resources
end
```

---

## Naming Reference

| GitHub repo name  | `brew tap` command      | Install command                        |
|-------------------|-------------------------|----------------------------------------|
| `homebrew-tap`    | `brew tap prog893/tap`  | `brew install prog893/tap/<formula>`   |

Homebrew convention: `brew tap user/foo` → `github.com/user/homebrew-foo`
So `homebrew-tap` → `brew tap prog893/tap`
