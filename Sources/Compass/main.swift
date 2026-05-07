import CompassRules
import Foundation
import NavigatorRules

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    FileHandle.standardError.write(Data("Usage: compass lint <path>\n".utf8))
    exit(64)
}

let command = arguments[1]
guard command == "lint" else {
    FileHandle.standardError.write(Data("Unknown command: \(command)\n".utf8))
    FileHandle.standardError.write(Data("Usage: compass lint <path>\n".utf8))
    exit(64)
}

let path = arguments.count >= 3 ? arguments[2] : "."
let url: URL
if path == "." {
    url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
} else {
    url = URL(fileURLWithPath: path)
}

var isDirectory: ObjCBool = false
guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
    FileHandle.standardError.write(Data("Error: '\(path)' does not exist\n".utf8))
    exit(66)
}

let engine = RuleEngine(rules: CompassDefaultRules.all())

do {
    let result =
        try isDirectory.boolValue
        ? engine.lint(directory: url)
        : engine.lint(file: url)

    if result.isValid {
        print("✓ All Markdown files pass all rules")
        exit(0)
    }

    print(
        "✗ Found \(result.totalViolationCount) violation(s) in \(result.fileViolations.count) file(s):\n"
    )

    for fileViolation in result.fileViolations {
        let relativePath = makeRelativePath(fileViolation.file, from: url)
        print("\(relativePath):")
        for violation in fileViolation.violations {
            var parts = ["[\(violation.ruleCode)]"]
            if let line = violation.line {
                parts.append("Line \(line):")
            }
            parts.append(violation.message)
            if let context = violation.context, !context.isEmpty {
                let contextStr =
                    context
                    .map { "\($0.key): \($0.value)" }
                    .joined(separator: ", ")
                parts.append("(\(contextStr))")
            }
            print("  " + parts.joined(separator: " "))
        }
        print("")
    }
    exit(1)
} catch {
    FileHandle.standardError.write(Data("Error: \(error)\n".utf8))
    exit(74)
}

func makeRelativePath(_ file: URL, from base: URL) -> String {
    base.path.isEmpty
        ? file.path
        : file.path.replacingOccurrences(of: base.path + "/", with: "")
}
