import Foundation

/// iTunes APIを使用したアプリ情報の検索サービス
@MainActor
final class AppLookupService {
    static let shared = AppLookupService()
    
    private init() {}
    
    struct LookupItem {
        let fileSizeBytes: String?
        let trackName: String?
    }
    
    /// バンドルIDでアプリ情報を検索
    func lookup(bundleID: String) async -> LookupItem? {
        await lookup(parameters: ["bundleId": bundleID])
    }
    
    /// アプリIDでアプリ情報を検索
    func lookup(appID: Int64) async -> LookupItem? {
        await lookup(parameters: ["id": String(appID)])
    }
    
    private func lookup(parameters: [String: String]) async -> LookupItem? {
        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        var items = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        items.append(URLQueryItem(name: "country", value: "us"))
        components?.queryItems = items
        
        guard let url = components?.url else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(LookupResponse.self, from: data)
            return response.results.first.map { LookupItem(fileSizeBytes: $0.fileSizeBytes, trackName: $0.trackName) }
        } catch {
            return nil
        }
    }
    
    /// 複数のトラックIDでアートワークURLを一括取得
    func lookupArtwork(trackIDs: [Int64]) async throws -> [Int64: URL] {
        let batchSize = 50
        var map: [Int64: URL] = [:]
        var currentIndex = 0
        
        while currentIndex < trackIDs.count {
            let chunk = Array(trackIDs[currentIndex..<min(currentIndex + batchSize, trackIDs.count)])
            let idsParam = chunk.map(String.init).joined(separator: ",")
            guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(idsParam)") else { break }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ArtworkLookupResponse.self, from: data)
            
            for result in response.results {
                if let urlString = result.artworkUrl512 ?? result.artworkUrl100 ?? result.artworkUrl60,
                   let parsedURL = URL(string: urlString) {
                    map[result.trackId] = parsedURL
                }
            }
            currentIndex += batchSize
        }
        
        return map
    }
}

private struct LookupResponse: Decodable {
    struct Item: Decodable {
        let fileSizeBytes: String?
        let trackName: String?
    }
    
    let results: [Item]
}

private struct ArtworkLookupResponse: Decodable {
    struct Result: Decodable {
        let trackId: Int64
        let artworkUrl60: String?
        let artworkUrl100: String?
        let artworkUrl512: String?
    }
    
    let results: [Result]
}
