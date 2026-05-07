import Foundation
import NavigatorRules

/// C001: every Markdown document must end with a footer that mentions
/// "Compass" — typically a brand line such as `Compass · 2026`.
///
/// The check walks back from end-of-file, skips trailing whitespace and
/// blank lines, and asserts the final visible line contains the literal
/// substring `Compass` (case-sensitive).
public struct C001_RequireCompassFooter: Rule {
    public let code = "C001"
    public let description = "every document must end with a footer line containing 'Compass'"

    /// Substring required on the document's last non-empty line.
    public let token: String

    public init(token: String = "Compass") {
        self.token = token
    }

    public func validate(file: URL) throws -> [Violation] {
        guard FileManager.default.fileExists(atPath: file.path) else {
            throw ValidationError.fileNotFound(file)
        }

        let content = try String(contentsOf: file, encoding: .utf8)
        let body = stripFrontmatter(content)
        let lines = body.components(separatedBy: "\n")

        guard let lastVisible = lastNonBlankLine(in: lines) else {
            return [
                Violation(
                    ruleCode: code,
                    message: "document is empty; expected a footer line containing '\(token)'"
                )
            ]
        }

        if lastVisible.line.contains(token) {
            return []
        }

        return [
            Violation(
                ruleCode: code,
                message: "last non-empty line must contain '\(token)'",
                line: lastVisible.lineNumber,
                context: ["found": lastVisible.line]
            )
        ]
    }

    private func lastNonBlankLine(in lines: [String]) -> (line: String, lineNumber: Int)? {
        for index in stride(from: lines.count - 1, through: 0, by: -1) {
            let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                return (lines[index], index + 1)
            }
        }
        return nil
    }

    /// Skip leading YAML frontmatter so a document that *only* contains
    /// frontmatter and a footer is not treated as empty.
    private func stripFrontmatter(_ content: String) -> String {
        let lines = content.components(separatedBy: "\n")
        guard lines.first == "---" else { return content }

        for (index, line) in lines.enumerated() where index > 0 && line == "---" {
            let remainder = lines[(index + 1)...]
            return remainder.joined(separator: "\n")
        }

        return content
    }
}
