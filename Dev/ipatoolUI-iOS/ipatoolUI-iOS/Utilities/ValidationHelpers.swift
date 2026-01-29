import Foundation

/// バリデーションヘルパー
enum ValidationHelpers {
    /// アプリIDまたはバンドルIDが有効かチェック
    static func isValidAppIDOrBundleID(appID: String, bundleID: String) -> Bool {
        if let _ = Int64(appID), !appID.isEmpty {
            return true
        }
        return !bundleID.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// バンドルIDが有効かチェック
    static func isValidBundleID(_ bundleID: String) -> Bool {
        !bundleID.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// バージョンIDが有効かチェック
    static func isValidVersionID(_ versionID: String) -> Bool {
        !versionID.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// 検索語が有効かチェック
    static func isValidSearchTerm(_ term: String) -> Bool {
        !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// メールアドレスとパスワードが有効かチェック
    static func isValidEmailAndPassword(email: String, password: String) -> Bool {
        !email.isEmpty && !password.isEmpty
    }
}

/// 文字列拡張
extension String {
    var nonEmptyOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }
}
