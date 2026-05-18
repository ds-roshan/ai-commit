# ai-commit

Generate meaningful git commit messages using Apple Intelligence — fully on-device, no API key, no internet required.

Analyses your staged changes (`git diff --staged`) and suggests commit messages in your preferred style. Pick one interactively, or pipe the output into scripts and Git hooks.

## Requirements

- macOS 26 (Tahoe) or later
- Apple Silicon (M1 or later)
- Apple Intelligence enabled — System Settings › Apple Intelligence & Siri

## Installation

### Homebrew (recommended)

```sh
brew tap ds-roshan/tap
brew install ai-commit
```

### Build from source

```sh
git clone https://github.com/ds-roshan/ai-commit.git
cd ai-commit
make install          # builds release binary and copies to /usr/local/bin
```

To uninstall:

```sh
make uninstall
```

### Pre-built binary

Download the latest binary from the [Releases](https://github.com/ds-roshan/ai-commit/releases) page, then:

```sh
chmod +x ai-commit
sudo mv ai-commit /usr/local/bin/ai-commit

# Remove Gatekeeper quarantine on first run
xattr -d com.apple.quarantine /usr/local/bin/ai-commit
```

## Quick start

```sh
# 1. Check that Apple Intelligence is available
ai-commit config show

# 2. Stage your changes
git add .

# 3. Generate suggestions and pick one
ai-commit

# 4. Or generate and commit in one step
ai-commit commit
```

## Usage

### Generate suggestions

```
ai-commit [--count <count>] [--style <style>] [--json] [--yes]
```

Generates commit message suggestions for your staged changes and presents an interactive picker. Nothing is committed.

| Flag | Description | Default |
|------|-------------|---------|
| `-c, --count` | Number of suggestions to generate (1–5) | `3` |
| `-s, --style` | Commit style: `conventional`, `free`, or `emoji` | from config |
| `--json` | Print suggestions as JSON (for scripting) | off |
| `-y, --yes` | Skip the picker and print the top suggestion | off |

**Examples:**

```sh
# Show 3 suggestions using your configured style
ai-commit

# Show 5 emoji-style suggestions
ai-commit --count 5 --style emoji

# Output as JSON for scripting
ai-commit --json

# Print the top suggestion without interaction
ai-commit --yes
```

---

### Commit

```
ai-commit commit [--count <count>] [--style <style>] [--yes]
```

Generates suggestions, presents the picker, then runs `git commit -m` with your chosen message.

```sh
# Pick from 3 suggestions and commit
ai-commit commit

# Commit immediately with the top suggestion (useful in scripts or Git hooks)
ai-commit commit --yes
```

---

### Config

```
ai-commit config show
ai-commit config set-style <style>
```

**Show current settings:**

```sh
ai-commit config show
```

```
Style:  conventional — Conventional (feat(scope): description)
Model:  Available
Config: /Users/you/.ai-commit.json
```

**Set your preferred commit style:**

```sh
ai-commit config set-style conventional   # feat(scope): description
ai-commit config set-style free           # plain English
ai-commit config set-style emoji          # ✨ description
```

Settings are saved to `~/.ai-commit.json` with `600` permissions.

---

## Commit styles

| Style | Example |
|-------|---------|
| `conventional` | `feat(ui): add dark mode toggle` |
| `free` | `Remove unused imports from config module` |
| `emoji` | `🐛 Fix off-by-one error in pagination` |

---

## Scripting and Git hooks

Use `--json` to consume suggestions in scripts:

```sh
ai-commit --json
# {
#   "suggestions" : [
#     "feat(ui): add dark mode toggle",
#     "remove unused imports from config module",
#     "🐛 fix off-by-one error in pagination"
#   ]
# }
```

Use `--yes` to auto-commit in a `prepare-commit-msg` Git hook:

```sh
#!/bin/sh
# .git/hooks/prepare-commit-msg
ai-commit commit --yes
```

---

## Privacy

All processing happens on-device using Apple's Foundation Models framework. Your code and commit history never leave your machine.

## License

MIT
