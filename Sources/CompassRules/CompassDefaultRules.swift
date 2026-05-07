import Foundation
import NavigatorRules

/// Canonical Compass rule set: every Navigator default rule plus the
/// Compass-specific extensions.
///
/// Compass is a strict superset of Navigator's lint surface — the
/// `compass` CLI accepts every document `navigator lint` accepts and
/// then enforces additional Foundation-specific conventions such as
/// the brand footer (``C001_RequireCompassFooter``).
///
/// ```swift
/// import NavigatorRules
/// import CompassRules
///
/// let engine = RuleEngine(rules: CompassDefaultRules.all())
/// let result = try engine.lint(directory: url)
/// ```
public enum CompassDefaultRules {
    /// Every Navigator default rule followed by the Compass extensions,
    /// in evaluation order.
    ///
    /// - Parameter validQuestionCodes: Forwarded to
    ///   `NavigatorDefaultRules.all(validQuestionCodes:)`. Defaults to
    ///   the Navigator-bundled question registry.
    public static func all(
        validQuestionCodes: Set<String>? = nil
    ) -> [Rule] {
        let navigatorRules: [Rule] =
            validQuestionCodes.map { NavigatorDefaultRules.all(validQuestionCodes: $0) }
            ?? NavigatorDefaultRules.all()

        return navigatorRules + compassRules()
    }

    /// Compass-specific rules layered on top of Navigator's defaults.
    public static func compassRules() -> [Rule] {
        [
            C001_RequireCompassFooter()
        ]
    }
}
