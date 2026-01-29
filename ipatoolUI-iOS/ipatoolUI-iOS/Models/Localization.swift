import Foundation
import Combine

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case japanese = "ja"
    case english = "en"
    case chinese = "zh-Hans"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .japanese: return "日本語"
        case .english: return "English"
        case .chinese: return "简体中文"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

struct LocalizedStrings {
    let language: AppLanguage
    
    // MARK: - Common
    var search: String {
        switch language {
        case .japanese: return "検索"
        case .english: return "Search"
        case .chinese: return "搜索"
        }
    }
    
    var settings: String {
        switch language {
        case .japanese: return "設定"
        case .english: return "Settings"
        case .chinese: return "设置"
        }
    }
    
    var cancel: String {
        switch language {
        case .japanese: return "キャンセル"
        case .english: return "Cancel"
        case .chinese: return "取消"
        }
    }
    
    var ok: String {
        switch language {
        case .japanese: return "OK"
        case .english: return "OK"
        case .chinese: return "确定"
        }
    }
    
    var copy: String {
        switch language {
        case .japanese: return "コピー"
        case .english: return "Copy"
        case .chinese: return "复制"
        }
    }
    
    // MARK: - Features
    var authentication: String {
        switch language {
        case .japanese: return "認証"
        case .english: return "Authentication"
        case .chinese: return "认证"
        }
    }
    
    var purchase: String {
        switch language {
        case .japanese: return "購入"
        case .english: return "Purchase"
        case .chinese: return "购买"
        }
    }
    
    var versions: String {
        switch language {
        case .japanese: return "バージョン"
        case .english: return "Versions"
        case .chinese: return "版本"
        }
    }
    
    var download: String {
        switch language {
        case .japanese: return "ダウンロード"
        case .english: return "Download"
        case .chinese: return "下载"
        }
    }
    
    var install: String {
        switch language {
        case .japanese: return "インストール"
        case .english: return "Install"
        case .chinese: return "安装"
        }
    }
    
    var installToSimulator: String {
        switch language {
        case .japanese: return "シミュレーターにインストール"
        case .english: return "Install to Simulator"
        case .chinese: return "安装到模拟器"
        }
    }
    
    var shareFile: String {
        switch language {
        case .japanese: return "ファイルを共有"
        case .english: return "Share File"
        case .chinese: return "分享文件"
        }
    }
    
    var deleteFile: String {
        switch language {
        case .japanese: return "ファイルを削除"
        case .english: return "Delete File"
        case .chinese: return "删除文件"
        }
    }
    
    var fileDeleted: String {
        switch language {
        case .japanese: return "ファイルを削除しました"
        case .english: return "File deleted"
        case .chinese: return "文件已删除"
        }
    }
    
    var versionMetadata: String {
        switch language {
        case .japanese: return "メタデータ"
        case .english: return "Version Metadata"
        case .chinese: return "版本元数据"
        }
    }
    
    var logs: String {
        switch language {
        case .japanese: return "ログ"
        case .english: return "Logs"
        case .chinese: return "日志"
        }
    }
    
    var about: String {
        switch language {
        case .japanese: return "アプリについて"
        case .english: return "About"
        case .chinese: return "关于"
        }
    }
    
    // MARK: - Auth
    var email: String {
        switch language {
        case .japanese: return "メールアドレス"
        case .english: return "Email"
        case .chinese: return "电子邮件"
        }
    }
    
    var password: String {
        switch language {
        case .japanese: return "パスワード"
        case .english: return "Password"
        case .chinese: return "密码"
        }
    }
    
    var authCode: String {
        switch language {
        case .japanese: return "認証コード（オプション）"
        case .english: return "Auth Code (Optional)"
        case .chinese: return "验证码（可选）"
        }
    }
    
    var login: String {
        switch language {
        case .japanese: return "ログイン"
        case .english: return "Login"
        case .chinese: return "登录"
        }
    }
    
    var logout: String {
        switch language {
        case .japanese: return "ログアウト"
        case .english: return "Logout"
        case .chinese: return "登出"
        }
    }
    
    var revoke: String {
        switch language {
        case .japanese: return "認証を無効化"
        case .english: return "Revoke"
        case .chinese: return "撤销"
        }
    }
    
    // MARK: - Search
    var searchTerm: String {
        switch language {
        case .japanese: return "検索語"
        case .english: return "Search Term"
        case .chinese: return "搜索词"
        }
    }
    
    var limit: String {
        switch language {
        case .japanese: return "結果数"
        case .english: return "Limit"
        case .chinese: return "结果数"
        }
    }
    
    var searchResults: String {
        switch language {
        case .japanese: return "検索結果"
        case .english: return "Search Results"
        case .chinese: return "搜索结果"
        }
    }
    
    var copyBundleID: String {
        switch language {
        case .japanese: return "バンドルIDをコピー"
        case .english: return "Copy Bundle ID"
        case .chinese: return "复制Bundle ID"
        }
    }
    
    var copyVersion: String {
        switch language {
        case .japanese: return "バージョンをコピー"
        case .english: return "Copy Version"
        case .chinese: return "复制版本"
        }
    }
    
    var purchased: String {
        switch language {
        case .japanese: return "購入済み"
        case .english: return "Purchased"
        case .chinese: return "已购买"
        }
    }
    
    var purchaseButton: String {
        switch language {
        case .japanese: return "購入"
        case .english: return "Purchase"
        case .chinese: return "购买"
        }
    }
    
    // MARK: - Settings
    var serverSettings: String {
        switch language {
        case .japanese: return "サーバー設定"
        case .english: return "Server Settings"
        case .chinese: return "服务器设置"
        }
    }
    
    var apiBaseURL: String {
        switch language {
        case .japanese: return "APIベースURL"
        case .english: return "API Base URL"
        case .chinese: return "API基础URL"
        }
    }
    
    var apiKey: String {
        switch language {
        case .japanese: return "APIキー（オプション）"
        case .english: return "API Key (Optional)"
        case .chinese: return "API密钥（可选）"
        }
    }
    
    var resetToDefault: String {
        switch language {
        case .japanese: return "デフォルトにリセット"
        case .english: return "Reset to Default"
        case .chinese: return "重置为默认值"
        }
    }
    
    var languageLabel: String {
        switch language {
        case .japanese: return "言語"
        case .english: return "Language"
        case .chinese: return "语言"
        }
    }
    
    var autoSystem: String {
        switch language {
        case .japanese: return "自動（システム）"
        case .english: return "Auto (System)"
        case .chinese: return "自动（系统）"
        }
    }
    
    var currencyDisplay: String {
        switch language {
        case .japanese: return "通貨表示"
        case .english: return "Currency Display"
        case .chinese: return "货币显示"
        }
    }
    
    var locale: String {
        switch language {
        case .japanese: return "ロケール"
        case .english: return "Locale"
        case .chinese: return "区域设置"
        }
    }
    
    var autoSystemAccount: String {
        switch language {
        case .japanese: return "自動（システム/アカウント）"
        case .english: return "Auto (System/Account)"
        case .chinese: return "自动（系统/账户）"
        }
    }
    
    var selected: String {
        switch language {
        case .japanese: return "選択:"
        case .english: return "Selected:"
        case .chinese: return "已选择："
        }
    }
    
    var using: String {
        switch language {
        case .japanese: return "使用中:"
        case .english: return "Using:"
        case .chinese: return "使用中："
        }
    }
    
    // MARK: - Other
    var version: String {
        switch language {
        case .japanese: return "バージョン"
        case .english: return "Version"
        case .chinese: return "版本"
        }
    }
    
    var unknown: String {
        switch language {
        case .japanese: return "不明"
        case .english: return "Unknown"
        case .chinese: return "未知"
        }
    }
    
    // MARK: - Form Fields
    var appID: String {
        switch language {
        case .japanese: return "アプリID"
        case .english: return "App ID"
        case .chinese: return "应用ID"
        }
    }
    
    var bundleID: String {
        switch language {
        case .japanese: return "バンドルID"
        case .english: return "Bundle ID"
        case .chinese: return "Bundle ID"
        }
    }
    
    var externalVersionIDOptional: String {
        switch language {
        case .japanese: return "外部バージョンID（オプション）"
        case .english: return "External Version ID (Optional)"
        case .chinese: return "外部版本ID（可选）"
        }
    }
    
    var versionID: String {
        switch language {
        case .japanese: return "バージョンID"
        case .english: return "Version ID"
        case .chinese: return "版本ID"
        }
    }
    
    var twoFactorAuthCodeOptional: String {
        switch language {
        case .japanese: return "2要素認証コード（オプション）"
        case .english: return "2FA Code (Optional)"
        case .chinese: return "双因素认证码（可选）"
        }
    }
    
    // MARK: - Sections
    var targetApp: String {
        switch language {
        case .japanese: return "対象アプリ"
        case .english: return "Target App"
        case .chinese: return "目标应用"
        }
    }
    
    var appInfo: String {
        switch language {
        case .japanese: return "アプリ情報"
        case .english: return "App Information"
        case .chinese: return "应用信息"
        }
    }
    
    var information: String {
        switch language {
        case .japanese: return "情報"
        case .english: return "Information"
        case .chinese: return "信息"
        }
    }
    
    var options: String {
        switch language {
        case .japanese: return "オプション"
        case .english: return "Options"
        case .chinese: return "选项"
        }
    }
    
    var status: String {
        switch language {
        case .japanese: return "ステータス"
        case .english: return "Status"
        case .chinese: return "状态"
        }
    }
    
    var error: String {
        switch language {
        case .japanese: return "エラー"
        case .english: return "Error"
        case .chinese: return "错误"
        }
    }
    
    var versionList: String {
        switch language {
        case .japanese: return "バージョン一覧"
        case .english: return "Version List"
        case .chinese: return "版本列表"
        }
    }
    
    var metadata: String {
        switch language {
        case .japanese: return "メタデータ"
        case .english: return "Metadata"
        case .chinese: return "元数据"
        }
    }
    
    var displayVersion: String {
        switch language {
        case .japanese: return "表示バージョン"
        case .english: return "Display Version"
        case .chinese: return "显示版本"
        }
    }
    
    var releaseDate: String {
        switch language {
        case .japanese: return "リリース日"
        case .english: return "Release Date"
        case .chinese: return "发布日期"
        }
    }
    
    var noLogsYet: String {
        switch language {
        case .japanese: return "ログはまだありません"
        case .english: return "No logs yet"
        case .chinese: return "暂无日志"
        }
    }
    
    var clearLogs: String {
        switch language {
        case .japanese: return "ログをクリア"
        case .english: return "Clear Logs"
        case .chinese: return "清除日志"
        }
    }
    
    var iosVersion: String {
        switch language {
        case .japanese: return "iOS版"
        case .english: return "iOS Version"
        case .chinese: return "iOS版本"
        }
    }
    
    var overview: String {
        switch language {
        case .japanese: return "概要"
        case .english: return "Overview"
        case .chinese: return "概述"
        }
    }
    
    var links: String {
        switch language {
        case .japanese: return "リンク"
        case .english: return "Links"
        case .chinese: return "链接"
        }
    }
    
    var appleID: String {
        switch language {
        case .japanese: return "Apple ID"
        case .english: return "Apple ID"
        case .chinese: return "Apple ID"
        }
    }
    
    // MARK: - Actions
    var signIn: String {
        switch language {
        case .japanese: return "サインイン"
        case .english: return "Sign In"
        case .chinese: return "登录"
        }
    }
    
    var accountInfo: String {
        switch language {
        case .japanese: return "アカウント情報"
        case .english: return "Account Info"
        case .chinese: return "账户信息"
        }
    }
    
    var deleteAuth: String {
        switch language {
        case .japanese: return "認証情報を削除"
        case .english: return "Delete Auth"
        case .chinese: return "删除认证信息"
        }
    }
    
    var downloadIPA: String {
        switch language {
        case .japanese: return "IPAをダウンロード"
        case .english: return "Download IPA"
        case .chinese: return "下载IPA"
        }
    }
    
    var autoPurchaseLicense: String {
        switch language {
        case .japanese: return "必要に応じて自動的にライセンスを購入"
        case .english: return "Auto-purchase license if needed"
        case .chinese: return "需要时自动购买许可证"
        }
    }
    
    var fetchVersions: String {
        switch language {
        case .japanese: return "バージョン一覧を取得"
        case .english: return "Fetch Versions"
        case .chinese: return "获取版本列表"
        }
    }
    
    var fetchMetadata: String {
        switch language {
        case .japanese: return "メタデータを取得"
        case .english: return "Fetch Metadata"
        case .chinese: return "获取元数据"
        }
    }
    
    var downloaded: String {
        switch language {
        case .japanese: return "ダウンロード済み"
        case .english: return "Downloaded"
        case .chinese: return "已下载"
        }
    }
    
    // MARK: - Messages
    var appIDOrBundleIDRequired: String {
        switch language {
        case .japanese: return "アプリIDまたはバンドルIDのいずれかを入力してください"
        case .english: return "Please enter either App ID or Bundle ID"
        case .chinese: return "请输入应用ID或Bundle ID"
        }
    }
    
    var versionIDRequired: String {
        switch language {
        case .japanese: return "バージョンIDは必須です。アプリIDまたはバンドルIDのいずれかを入力してください"
        case .english: return "Version ID is required. Please enter either App ID or Bundle ID"
        case .chinese: return "版本ID是必需的。请输入应用ID或Bundle ID"
        }
    }
    
    var enterBundleIDToPurchase: String {
        switch language {
        case .japanese: return "購入したいアプリのバンドルIDを入力してください"
        case .english: return "Enter the Bundle ID of the app you want to purchase"
        case .chinese: return "请输入要购买的应用的Bundle ID"
        }
    }
    
    var appDescription: String {
        switch language {
        case .japanese: return "ipatool-serverのAPIを使用してIPAファイルをダウンロードできるiOSアプリです。"
        case .english: return "An iOS app that can download IPA files using the ipatool-server API."
        case .chinese: return "一个可以使用ipatool-server API下载IPA文件的iOS应用。"
        }
    }
    
    var macVersionFeatures: String {
        switch language {
        case .japanese: return "Mac版ipatoolUIの全機能をiOSで利用できます。"
        case .english: return "All features of the Mac version of ipatoolUI are available on iOS."
        case .chinese: return "Mac版ipatoolUI的所有功能都可在iOS上使用。"
        }
    }
    
    // MARK: - Error Messages
    var appIDOrBundleIDRequiredError: String {
        switch language {
        case .japanese: return "アプリIDまたはバンドルIDを入力してください"
        case .english: return "Please enter either App ID or Bundle ID"
        case .chinese: return "请输入应用ID或Bundle ID"
        }
    }
    
    var searchTermRequired: String {
        switch language {
        case .japanese: return "検索語を入力してください"
        case .english: return "Please enter a search term"
        case .chinese: return "请输入搜索词"
        }
    }
    
    var bundleIDRequired: String {
        switch language {
        case .japanese: return "バンドルIDを入力してください"
        case .english: return "Please enter a Bundle ID"
        case .chinese: return "请输入Bundle ID"
        }
    }
    
    var versionIDRequiredError: String {
        switch language {
        case .japanese: return "バージョンIDを入力してください"
        case .english: return "Please enter a Version ID"
        case .chinese: return "请输入版本ID"
        }
    }
    
    var emailPasswordRequired: String {
        switch language {
        case .japanese: return "メールアドレスとパスワードを入力してください"
        case .english: return "Please enter email and password"
        case .chinese: return "请输入电子邮件和密码"
        }
    }
    
    var fileNotFound: String {
        switch language {
        case .japanese: return "削除するファイルが見つかりません"
        case .english: return "File not found"
        case .chinese: return "未找到文件"
        }
    }
    
    var loginFailed: String {
        switch language {
        case .japanese: return "ログインに失敗しました"
        case .english: return "Login failed"
        case .chinese: return "登录失败"
        }
    }
    
    var purchaseFailed: String {
        switch language {
        case .japanese: return "購入に失敗しました"
        case .english: return "Purchase failed"
        case .chinese: return "购买失败"
        }
    }
    
    var fetchVersionsFailed: String {
        switch language {
        case .japanese: return "バージョン一覧の取得に失敗しました"
        case .english: return "Failed to fetch versions"
        case .chinese: return "获取版本列表失败"
        }
    }
    
    var fetchMetadataFailed: String {
        switch language {
        case .japanese: return "メタデータの取得に失敗しました"
        case .english: return "Failed to fetch metadata"
        case .chinese: return "获取元数据失败"
        }
    }
    
    // MARK: - Status Messages
    var unauthenticated: String {
        switch language {
        case .japanese: return "未認証"
        case .english: return "Unauthenticated"
        case .chinese: return "未认证"
        }
    }
    
    var signedInAs: String {
        switch language {
        case .japanese: return "としてサインインしました"
        case .english: return "Signed in as"
        case .chinese: return "已登录为"
        }
    }
    
    var activeSession: String {
        switch language {
        case .japanese: return "アクティブなセッション:"
        case .english: return "Active session:"
        case .chinese: return "活动会话："
        }
    }
    
    var authDeleted: String {
        switch language {
        case .japanese: return "認証情報を削除しました"
        case .english: return "Authentication deleted"
        case .chinese: return "已删除认证信息"
        }
    }
    
    var appsFound: String {
        switch language {
        case .japanese: return "件のアプリが見つかりました"
        case .english: return "apps found"
        case .chinese: return "个应用已找到"
        }
    }
    
    var purchaseSuccess: String {
        switch language {
        case .japanese: return "の購入に成功しました"
        case .english: return "purchased successfully"
        case .chinese: return "购买成功"
        }
    }
    
    var purchaseCompletedNoFlag: String {
        switch language {
        case .japanese: return "購入コマンドは完了しましたが、成功フラグがありません"
        case .english: return "Purchase command completed but success flag is missing"
        case .chinese: return "购买命令已完成，但缺少成功标志"
        }
    }
    
    var fileSaved: String {
        switch language {
        case .japanese: return "を保存しました"
        case .english: return "saved"
        case .chinese: return "已保存"
        }
    }
    
    var versionsFound: String {
        switch language {
        case .japanese: return "件のバージョンが見つかりました"
        case .english: return "versions found"
        case .chinese: return "个版本已找到"
        }
    }
    
    var metadataFetched: String {
        switch language {
        case .japanese: return "メタデータを取得しました"
        case .english: return "Metadata fetched"
        case .chinese: return "已获取元数据"
        }
    }
}

// Global localization instance
@MainActor
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: AppLanguage {
        didSet {
            strings = LocalizedStrings(language: currentLanguage)
        }
    }
    
    @Published var strings: LocalizedStrings
    
    static let shared = LocalizationManager()
    
    private init() {
        // Load from UserDefaults or default to system language
        let initialLanguage: AppLanguage
        if let savedLanguageCode = UserDefaults.standard.string(forKey: "appLanguage"),
           let savedLanguage = AppLanguage(rawValue: savedLanguageCode) {
            initialLanguage = savedLanguage
        } else {
            // Detect system language
            let systemLanguage = Locale.preferredLanguages.first ?? "en"
            if systemLanguage.hasPrefix("ja") {
                initialLanguage = .japanese
            } else if systemLanguage.hasPrefix("zh") {
                initialLanguage = .chinese
            } else {
                initialLanguage = .english
            }
        }
        
        // Initialize strings first, then currentLanguage (to avoid didSet accessing uninitialized strings)
        strings = LocalizedStrings(language: initialLanguage)
        currentLanguage = initialLanguage
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
    }
}
