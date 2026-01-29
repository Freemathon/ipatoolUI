import Foundation

/// ファイル名生成のヘルパー
enum FilenameHelper {
    /// アプリ名から安全なファイル名を生成
    static func sanitize(name: String) -> String {
        let sanitized = name.replacingOccurrences(
            of: "[^A-Za-z0-9._-]",
            with: "-",
            options: .regularExpression
        )
        return sanitized.isEmpty ? "ipatool-download.ipa" : "\(sanitized).ipa"
    }
    
    /// バンドルIDからファイル名を生成
    static func filename(fromBundleID bundleID: String) -> String {
        sanitize(name: bundleID)
    }
    
    /// アプリIDからファイル名を生成
    static func filename(fromAppID appID: String) -> String {
        "App-\(appID).ipa"
    }
    
    /// デフォルトファイル名
    static let defaultFilename = "ipatool-download.ipa"
}
