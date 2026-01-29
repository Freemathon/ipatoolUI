import Foundation

/// ファイル管理の共通ロジックを提供するサービス
@MainActor
final class FileManagerService {
    static let shared = FileManagerService()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    /// Documentsディレクトリのパスを取得
    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// 一時ディレクトリのパスを取得
    var temporaryDirectory: URL {
        fileManager.temporaryDirectory
    }
    
    /// 一時ファイルを作成
    func createTempFile(extension ext: String = "ipa") throws -> URL {
        let tempDir = temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
        
        if !fileManager.fileExists(atPath: tempFileURL.path) {
            fileManager.createFile(atPath: tempFileURL.path, contents: nil, attributes: nil)
        }
        
        return tempFileURL
    }
    
    /// ファイルをDocumentsディレクトリに移動
    func moveToDocuments(from sourceURL: URL, filename: String) throws -> URL {
        var destinationURL = documentsDirectory.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.moveItem(at: sourceURL, to: destinationURL)
        
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = false
        try? destinationURL.setResourceValues(resourceValues)
        
        return destinationURL
    }
    
    /// ファイルを削除
    func deleteFile(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }
    
    /// ファイルが存在するか確認
    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    /// Documents内の .ipa ファイル一覧を取得（更新日時降順）
    func listIPAFiles() -> [URL] {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: documentsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return [] }
        
        return contents
            .filter { $0.pathExtension.lowercased() == "ipa" }
            .sorted { url1, url2 in
                let d1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let d2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                return d1 > d2
            }
    }
    
    /// Documents内の全 .ipa を削除
    func deleteAllIPAFiles() throws {
        let urls = listIPAFiles()
        for url in urls {
            try fileManager.removeItem(at: url)
        }
    }
}
