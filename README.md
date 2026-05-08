# Compass

![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)

A Markdown linter that extends [Navigator](https://github.com/neon-law-foundation/Navigator)
with Foundation-specific rules. Compass is a **strict superset** of
`navigator lint` — every rule the Navigator CLI runs, plus extra
conventions Foundation documents must follow.

## What it adds

| Code | Description |
|------|-------------|
| C001 | Every Markdown document must end with a footer line containing `Compass`. |

If you can think of a convention worth enforcing across Foundation
docs, it lives here rather than upstream in Navigator.

## Why this repo exists

Compass is the reference downstream of `NavigatorRules`. The seam was
opened by
[Navigator#7](https://github.com/neon-law-foundation/Navigator/pull/8):
`RuleEngine`, `FileFilters`, and `NavigatorDefaultRules.all()` are all
public on `NavigatorRules`, so Compass adds rules without copying any
engine wiring:

```swift
import CompassRules
import NavigatorRules

let engine = RuleEngine(rules: CompassDefaultRules.all())
let result = try engine.lint(directory: url)
```

`CompassDefaultRules.all()` returns
`NavigatorDefaultRules.all() + [C001_RequireCompassFooter()]` — the
ordering guarantee is locked in by `CompassDefaultRulesTests`.

## Install

### Build from source

```bash
git clone https://github.com/neon-law-foundation/Compass.git
cd Compass
swift build -c release --product Compass
install -Dm755 .build/release/Compass ~/.local/bin/compass
```

Make sure `~/.local/bin` is on your `PATH`, then:

```bash
compass lint .
```

Compass pins Navigator to the exact commit behind the
[`v2026.05.08`](https://github.com/neon-law-foundation/Navigator/releases/tag/v2026.05.08)
release tag (SHA `18241315c91c375a11494332d43f3fca4e4570f6`). Navigator's
tag format (`vYYYY.MM.DD`) isn't semver-compatible, so SPM's
`.exact(_:)` can't be used directly — `.revision(_:)` against the
release SHA is strictly more exact and rolls forward only when this
file is changed.

A Homebrew formula will follow.

## Usage

```bash
compass lint <path>
```

`<path>` may be a single `.md` file or a directory. Exit code `0` means
clean; `1` means at least one violation. Output mirrors `navigator lint`:

```text
docs/Charter.md:
  [C001] Line 14: last non-empty line must contain 'Compass' (found: ## End)
```

## The C001 rule

`C001_RequireCompassFooter` walks back from end-of-file, skips blank
lines and trailing whitespace, and asserts the last visible line
contains the literal substring `Compass` (case-sensitive). YAML
frontmatter is ignored when searching for the footer, so a document
that contains *only* frontmatter still fails.

Pass a custom token if your project brands the footer differently:

```swift
let rules = NavigatorDefaultRules.all() + [
    C001_RequireCompassFooter(token: "Foundation")
]
```

## Adding more rules

Drop a new file under `Sources/CompassRules/`, conform to
[`Rule`](https://github.com/neon-law-foundation/Navigator/blob/main/Sources/NavigatorRules/Protocols/Rule.swift)
or `FixableRule`, and append it to
`CompassDefaultRules.compassRules()`:

```swift
public struct C002_RequireAuthor: Rule {
    public let code = "C002"
    public let description = "frontmatter must include an 'author' field"
    public func validate(file: URL) throws -> [Violation] {
        // ... uses NavigatorRules.FrontmatterParser ...
    }
}
```

The shared parsing utilities (`FrontmatterParser`, `BlockTokenizer`,
`LineScanner`, `ATXHeadingParser`, `TableTokenizer`,
`ReferenceCollector`, `InlineTokenizer`, `ListParser`) are all public
on `NavigatorRules`.

## Development

```bash
swift build
swift test
swift format -i -r .
swift format lint --strict --recursive --parallel --no-color-diagnostics .
```

Compass · 2026
