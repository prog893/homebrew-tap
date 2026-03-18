# homebrew-tap Development Guide

> **⚠️ Private Repository Notice**
>
> This tap repository is **private** as of 2025-03-19 with no current plans to become public.
>
> Users must authenticate with GitHub before tapping — see README.md for setup instructions.
>
> **Developer setup:** You need SSH key access for pushing formula updates during releases.

This repo is the single Homebrew tap for all `prog893` CLI tools.
Users: `brew tap prog893/tap` → `brew install <tool-name>`


## Onboarding a New Tool

When asked to onboard a tool, work through the questions below **in order**. Ask each question, wait for the answer, then proceed. Do not skip ahead.

---

### Step 1 — Tool name

> **"What is the tool name?"**

- Must be lowercase, hyphen-separated (e.g. `my-tool`)
- This becomes `Formula/my-tool.rb` and the install command `brew install my-tool`
- Formula class name is PascalCase (e.g. `MyTool`)

---

### Step 2 — Where does the tool live?

> **"Does this tool already have its own GitHub repo, or will it live inside this tap repo?"**

**Option A — Own repo** (like `staqan-yt-cli`):
- Tool source code lives at `github.com/prog893/<tool-name>`
- Formula points to that repo via git tag URL
- Tool repo is responsible for pushing formula version updates here
- → Continue to Step 3

**Option B — Lives inside the tap** (simple scripts, one-off tools):
- Tool source code lives directly in this repo (e.g. `tools/<tool-name>/`)
- Formula points to a raw file or tarball URL in this repo
- Version updates are done manually here
- → Skip to Step 5

---

### Step 3 — README (own-repo tools only)

> **"Does the tool already have a README in its repo?"**

**Yes** → Read it (or ask for the URL/path). Extract:
  - One-line description for `desc`
  - Homepage URL
  - Any special install/runtime requirements

**No** → Offer to generate one from the code:
  - Ask: *"Should I generate a README from the source code?"*
  - If yes: read the entrypoint and commands, draft a README, write it to the tool's repo
  - The README should cover: what the tool does, install steps (`brew install <tool>`), usage examples, any required setup (credentials, config, etc.)

---

### Step 4 — Runtime & build (own-repo tools only)

> **"What runtime does the tool use?"**

| Answer | `depends_on` | `install` approach |
|--------|-------------|-------------------|
| Bun / TypeScript | `"oven-sh/bun/bun"` | `bun install` + `bun build --compile` |
| Node.js | `"node"` | `npm install` + copy entrypoint |
| Python | `"python@3.x"` | `virtualenv_install_with_resources` |
| Shell script | none | `bin.install "script.sh" => "tool-name"` |
| Go | none (statically compiled) | `system "go", "build", "-o", "tool-name"` |

Also ask:
- **"What is the entrypoint file?"** (e.g. `bin/staqan-yt.ts`, `main.py`, `tool.sh`)
- **"Should shell completions be installed?"** (zsh/bash — only if the tool supports `completion` subcommand)

---

### Step 5 — Write the formula

Create `Formula/<tool-name>.rb` using the appropriate template below.

#### Template: Bun/TypeScript (own repo)

```ruby
class ToolName < Formula
  desc "One-line description from README"
  homepage "https://github.com/prog893/<tool-name>"
  version "X.Y.Z"
  license "MIT"

  url "https://github.com/prog893/<tool-name>.git",
      tag: "v#{version}"

  depends_on "oven-sh/bun/bun"

  def install
    bun = Formula["bun"].opt_bin/"bun"
    system bun, "install"
    if Hardware::CPU.arm?
      system bun, "build", "./bin/<tool-name>.ts", "--compile", "--target=bun-darwin-arm64", "--outfile", "<tool-name>"
    else
      system bun, "build", "./bin/<tool-name>.ts", "--compile", "--target=bun-darwin-x64", "--outfile", "<tool-name>"
    end
    bin.install "<tool-name>"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/<tool-name> --version")
  end
end
```

#### Template: Shell script (lives in tap)

```ruby
class ToolName < Formula
  desc "One-line description"
  homepage "https://github.com/prog893/homebrew-tap"
  version "X.Y.Z"
  license "MIT"

  url "https://raw.githubusercontent.com/prog893/homebrew-tap/v#{version}/tools/<tool-name>/<tool-name>.sh"
  sha256 "<run: shasum -a 256 <file>>"

  def install
    bin.install "<tool-name>.sh" => "<tool-name>"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/<tool-name> --version")
  end
end
```

#### Template: Python (own repo)

```ruby
class ToolName < Formula
  desc "One-line description"
  homepage "https://github.com/prog893/<tool-name>"
  version "X.Y.Z"
  license "MIT"

  url "https://github.com/prog893/<tool-name>.git",
      tag: "v#{version}"

  depends_on "python@3.12"

  def install
    virtualenv_create(libexec, "python3")
    system libexec/"bin/pip", "install", "-v", "--no-deps", "--ignore-installed", buildpath
    bin.install_symlink libexec/"bin/<tool-name>"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/<tool-name> --version")
  end
end
```

---

### Step 6 — Update README.md in this repo

Add a row to the tools table:

```markdown
| tool-name | Short description |
```

---

### Step 7 — Release automation (own-repo tools only)

> **"Does the tool repo have release scripts (like `scripts/postversion.ts`) or is versioning manual?"**

**Has release scripts** → Update them to:
1. Write the updated formula version to `homebrew-tap/Formula/<tool-name>.rb`
2. Commit `"<tool-name> X.Y.Z"` and push to this repo

Pattern to follow: see `staqan-yt-cli/scripts/version.ts` and `postversion.ts`.

**No release scripts / manual** → Note in the formula's comment that version must be bumped manually here.

---

### Step 8 — Verify

```bash
# Tap is already added — just install
brew install <tool-name>

# Verify
<tool-name> --version
```

---

## Version Update Process (automated tools)

1. Tool repo bumps version (`npm version patch`)
2. `scripts/version.ts` writes updated `.rb` to a local clone of this repo
3. `scripts/postversion.ts` commits `"<tool> X.Y.Z"` and pushes here

Human review not required for version-only commits.

---

## Tap Conventions

- One `.rb` per tool in `Formula/`, named `<tool-name>.rb`
- Formula class: PascalCase (`StaqanYt` for `staqan-yt`)
- Required fields: `desc`, `homepage`, `version`, `url`, `license`, `install`, `test`
- Source-based installs (git tag URL) preferred for private repos

---

## Naming Reference

| GitHub repo name | `brew tap` command     | Install command          |
|------------------|------------------------|--------------------------|
| `homebrew-tap`   | `brew tap prog893/tap` | `brew install <formula>` |

Homebrew: `brew tap user/foo` → `github.com/user/homebrew-foo`
So `homebrew-tap` → `brew tap prog893/tap`
