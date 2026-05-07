import CompassRules
import Foundation
import NavigatorRules
import Testing

@Suite("CompassDefaultRules")
struct CompassDefaultRulesTests {
    @Test("all() is a strict superset of NavigatorDefaultRules.all()")
    func testSupersetOfNavigatorDefaults() {
        let navigatorCodes = Set(NavigatorDefaultRules.all().map(\.code))
        let compassCodes = Set(CompassDefaultRules.all().map(\.code))

        #expect(navigatorCodes.isSubset(of: compassCodes))
    }

    @Test("all() preserves Navigator's canonical order, then appends Compass rules")
    func testOrdering() {
        let navigatorCodes = NavigatorDefaultRules.all().map(\.code)
        let compassCodes = CompassDefaultRules.all().map(\.code)

        #expect(Array(compassCodes.prefix(navigatorCodes.count)) == navigatorCodes)
    }

    @Test("Compass extensions include C001")
    func testIncludesCompassFooterRule() {
        let extensionCodes = CompassDefaultRules.compassRules().map(\.code)
        #expect(extensionCodes.contains("C001"))
    }

    @Test("RuleEngine flags missing Compass footer on a directory of one file")
    func testEngineFlagsMissingFooter() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CompassDefaultRulesTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let file = dir.appendingPathComponent("NoFooter.md")
        try "# No Footer\n\nBody only.\n".write(to: file, atomically: true, encoding: .utf8)

        let engine = RuleEngine(rules: CompassDefaultRules.all())
        let result = try engine.lint(directory: dir)

        let c001 = result.fileViolations
            .flatMap(\.violations)
            .filter { $0.ruleCode == "C001" }
        #expect(c001.count == 1)
    }
}
