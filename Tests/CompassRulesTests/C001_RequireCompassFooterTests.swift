import CompassRules
import Foundation
import NavigatorRules
import Testing

@Suite("C001_RequireCompassFooter")
struct C001_RequireCompassFooterTests {
    @Test("Document ending with 'Compass · 2026' passes")
    func testFooterPresentPasses() throws {
        let url = try writeTempMarkdown(
            """
            # Doc

            Body text.

            Compass · 2026
            """
        )
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter()
        #expect(try rule.validate(file: url).isEmpty)
    }

    @Test("Document with trailing blank lines after the footer still passes")
    func testTrailingBlanksTolerated() throws {
        let url = try writeTempMarkdown(
            """
            # Doc

            Body.

            Compass · 2026


            """
        )
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter()
        #expect(try rule.validate(file: url).isEmpty)
    }

    @Test("Document missing footer fails with C001")
    func testMissingFooterFails() throws {
        let url = try writeTempMarkdown(
            """
            # Doc

            Body text without a footer.
            """
        )
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter()
        let violations = try rule.validate(file: url)
        #expect(violations.count == 1)
        #expect(violations.first?.ruleCode == "C001")
    }

    @Test("Empty document fails with C001")
    func testEmptyDocumentFails() throws {
        let url = try writeTempMarkdown("")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter()
        let violations = try rule.validate(file: url)
        #expect(violations.count == 1)
        #expect(violations.first?.ruleCode == "C001")
    }

    @Test("Frontmatter-only document fails with C001")
    func testFrontmatterOnlyFails() throws {
        let url = try writeTempMarkdown(
            """
            ---
            title: Test
            ---
            """
        )
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter()
        let violations = try rule.validate(file: url)
        #expect(violations.count == 1)
    }

    @Test("Frontmatter is ignored when locating the footer")
    func testFrontmatterIgnored() throws {
        let url = try writeTempMarkdown(
            """
            ---
            title: Test
            ---

            # Doc

            Compass · 2026
            """
        )
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter()
        #expect(try rule.validate(file: url).isEmpty)
    }

    @Test("Custom token is honored")
    func testCustomToken() throws {
        let url = try writeTempMarkdown(
            """
            # Doc

            Body.

            Foundation © 2026
            """
        )
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter(token: "Foundation")
        #expect(try rule.validate(file: url).isEmpty)
    }

    @Test("Token match is case-sensitive")
    func testCaseSensitivity() throws {
        let url = try writeTempMarkdown(
            """
            # Doc

            Body.

            compass · 2026
            """
        )
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let rule = C001_RequireCompassFooter()
        #expect(!(try rule.validate(file: url).isEmpty))
    }

    private func writeTempMarkdown(_ contents: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CompassRulesTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("Doc.md")
        try contents.write(to: file, atomically: true, encoding: .utf8)
        return file
    }
}
