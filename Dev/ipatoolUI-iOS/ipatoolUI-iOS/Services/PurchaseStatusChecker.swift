import Foundation

/// Service for checking purchase status of apps
final class PurchaseStatusChecker {
    private let apiService: APIService
    private let purchaseSemaphore: AsyncSemaphore
    
    init(apiService: APIService, semaphoreLimit: Int = 4) {
        self.apiService = apiService
        self.purchaseSemaphore = AsyncSemaphore(limit: semaphoreLimit)
    }
    
    /// Check purchase status for an app
    /// Returns true if the app is purchased, false otherwise
    @MainActor
    func checkPurchaseStatus(for app: AppInfo) async -> Bool {
        guard purchaseKey(for: app) != nil else { return false }
        
        await purchaseSemaphore.wait()
        defer {
            Task { await purchaseSemaphore.signal() }
        }
        
        let commands = listVersionsCommands(for: app)
        guard !commands.isEmpty else { return false }
        
        let maxAttemptsPerCommand = 2
        let retryDelay: UInt64 = 400_000_000 // 0.4 seconds
        
        commandLoop: for command in commands {
            for attempt in 0..<maxAttemptsPerCommand {
                do {
                    _ = try await apiService.listVersions(
                        bundleID: command.bundleID,
                        appID: command.appID
                    )
                    return true
                } catch let error as APIError {
                    if case .serverError(let code, let message) = error,
                       code == 403 || message.localizedCaseInsensitiveContains("license is required") {
                        continue commandLoop
                    }
                    if attempt < maxAttemptsPerCommand - 1 {
                        try? await Task.sleep(nanoseconds: retryDelay)
                    }
                } catch {
                    if attempt < maxAttemptsPerCommand - 1 {
                        try? await Task.sleep(nanoseconds: retryDelay)
                    }
                }
            }
        }
        
        // If all commands failed, the app is not purchased
        return false
    }
    
    // MARK: - Helpers
    
    func purchaseKey(for app: AppInfo) -> String? {
        if let bundle = app.bundleID, !bundle.isEmpty {
            return purchaseKey(forBundle: bundle)
        }
        if let trackID = app.trackID {
            return purchaseKey(forTrackID: trackID)
        }
        return nil
    }
    
    func purchaseKey(forBundle bundle: String) -> String {
        "bundle::\(bundle.lowercased())"
    }
    
    func purchaseKey(forTrackID trackID: Int64) -> String {
        "track::\(trackID)"
    }
    
    private struct ListVersionsCommand {
        let bundleID: String?
        let appID: Int64?
    }
    
    private func listVersionsCommands(for app: AppInfo) -> [ListVersionsCommand] {
        var commands: [ListVersionsCommand] = []
        if let bundle = app.bundleID, !bundle.isEmpty {
            commands.append(ListVersionsCommand(bundleID: bundle, appID: nil))
        }
        if let trackID = app.trackID {
            commands.append(ListVersionsCommand(bundleID: nil, appID: trackID))
        }
        return commands
    }
}
