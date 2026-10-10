import Foundation

/// Localizes built-in labels kept as strings, without changing their stored identifiers.
nonisolated enum L10n {
    static func string(_ key: String, bundle: Bundle = .main) -> String {
        bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }
}
