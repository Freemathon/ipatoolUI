# ipatoolUI iOS版

ipatool-serverのAPIを使用してIPAファイルをダウンロードできるiOSアプリです。

## 機能

Mac版ipatoolUIの全機能をiOSで利用できます：

- **認証**: Apple IDでログイン、アカウント情報取得、認証情報削除
- **検索**: App Storeでアプリを検索
- **購入**: アプリのライセンスを購入
- **バージョン一覧**: アプリの利用可能なバージョン一覧を取得
- **メタデータ**: 特定バージョンのメタデータを取得
- **ダウンロード**: IPAファイルをダウンロード（進捗表示付き）
- **設定**: サーバーURLとAPIキーの設定
- **ログ**: 操作ログの表示

## デザイン

- Apple Human Interface Guidelines (HIG) 準拠
- iOS 17+のモダンなデザイン
- SwiftUIを使用したネイティブUI
- タブベースのナビゲーション

## 使用方法

### 1. ipatool-serverの起動

まず、ipatool-serverを起動する必要があります：

```bash
ipatool server --port 8080
```

または、APIキー認証付きで起動：

```bash
ipatool server --port 8080 --api-key "your-secret-key"
```

### 2. アプリの設定

1. アプリを起動
2. 「設定」タブを開く
3. 「APIベースURL」にサーバーのURLを入力（例: `http://localhost:8080`）
4. APIキーが設定されている場合は「APIキー」に入力

### 3. 認証

1. 「認証」タブを開く
2. Apple IDのメールアドレスとパスワードを入力
3. 2要素認証が有効な場合は、認証コードを入力
4. 「サインイン」をタップ

### 4. アプリの検索とダウンロード

1. 「検索」タブでアプリを検索
2. 必要に応じて「購入」タブでライセンスを購入
3. 「ダウンロード」タブでIPAファイルをダウンロード

## プロジェクト構造

```
ipatoolUI-iOS/
├── Services/
│   └── APIService.swift          # ipatool-server API クライアント
├── Models/
│   ├── AppState.swift            # アプリケーション状態管理
│   └── APIResponseModels.swift   # APIレスポンスモデル
├── ViewModels/
│   ├── AuthViewModel.swift       # 認証ViewModel
│   ├── SearchViewModel.swift     # 検索ViewModel
│   ├── PurchaseViewModel.swift    # 購入ViewModel
│   ├── DownloadViewModel.swift    # ダウンロードViewModel
│   ├── ListVersionsViewModel.swift # バージョン一覧ViewModel
│   └── VersionMetadataViewModel.swift # メタデータViewModel
├── Views/
│   ├── MainView.swift            # メインビュー（TabView）
│   ├── AuthView.swift            # 認証画面
│   ├── SearchView.swift          # 検索画面
│   ├── PurchaseView.swift        # 購入画面
│   ├── DownloadView.swift        # ダウンロード画面
│   ├── ListVersionsView.swift    # バージョン一覧画面
│   ├── VersionMetadataView.swift # メタデータ画面
│   ├── SettingsView.swift        # 設定画面
│   ├── LogsView.swift            # ログ画面
│   └── AboutView.swift          # アプリについて画面
└── ipatoolUIApp.swift            # アプリエントリーポイント
```

## 要件

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 注意事項

- このアプリはipatool-serverが起動している必要があります
- ローカルネットワークで使用する場合は、サーバーのIPアドレスを指定してください（例: `http://192.168.1.100:8080`）
- インターネット経由で使用する場合は、適切なセキュリティ設定（HTTPS、APIキー認証など）を推奨します

## ライセンス

Mac版ipatoolUIと同じライセンスに準拠します。
