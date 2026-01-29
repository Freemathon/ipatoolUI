import Foundation

/// 日付フォーマットのヘルパー
enum DateFormatterHelper {
    /// ISO8601日付文字列をローカライズされた日付文字列に変換
    static func formatDate(_ dateString: String, locale: Locale) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        displayFormatter.locale = locale
        return displayFormatter.string(from: date)
    }
}
