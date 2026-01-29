import Foundation
import Combine

@MainActor
final class DownloadViewModel: BaseViewModel {
    @Published var appIDString: String = ""
    @Published var bundleIdentifier: String = ""
    @Published var externalVersionID: String = ""
    @Published var shouldAutoPurchase: Bool = false
    @Published var isDownloading: Bool = false
    @Published var downloadedBytes: Int64 = 0
    @Published var expectedBytes: Int64?
    @Published var suggestedFilename: String = "App.ipa"
    @Published var lastDownloadedURL: URL? = nil
    
    private let fileManagerService = FileManagerService.shared
    private let lookupService = AppLookupService.shared
    private var cachedAppName: String? {
        didSet { updateSuggestedFilename() }
    }
    
    func download() {
        guard ValidationHelpers.isValidAppIDOrBundleID(appID: appIDString, bundleID: bundleIdentifier) else {
            activeError = .serverError(400, localizationManager.strings.appIDOrBundleIDRequiredError)
            return
        }
        
        isDownloading = true
        isLoading = true
        clearError()
        statusMessage = nil
        downloadedBytes = 0
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let appID = Int64(self.appIDString)
                
                if let expected = await self.fetchExpectedSize() {
                    self.expectedBytes = expected
                }
                
                let (tempFileURL, filename) = try await apiService.downloadToFile(
                    bundleID: self.bundleIdentifier.isEmpty ? nil : self.bundleIdentifier,
                    appID: appID,
                    externalVersionID: self.externalVersionID.isEmpty ? nil : self.externalVersionID,
                    autoPurchase: self.shouldAutoPurchase
                ) { downloaded, total in
                    Task { @MainActor in
                        self.downloadedBytes = downloaded
                        self.expectedBytes = total
                    }
                }
                
                let fileURL = try fileManagerService.moveToDocuments(from: tempFileURL, filename: filename)
                self.lastDownloadedURL = fileURL
                self.statusMessage = "\(filename) \(self.localizationManager.strings.fileSaved)"
            } catch {
                self.handleError(error)
            }
            
            self.isDownloading = false
            self.isLoading = false
            self.expectedBytes = nil
            self.downloadedBytes = 0
        }
    }
    
    private func fetchExpectedSize() async -> Int64? {
        let trimmedBundle = bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedBundle.isEmpty, let item = await lookupService.lookup(bundleID: trimmedBundle) {
            await MainActor.run {
                if let name = item.trackName?.nonEmptyOrNil {
                    cachedAppName = name
                }
            }
            if let bytes = item.fileSizeBytes, let parsed = Int64(bytes) {
                return parsed
            }
        }
        if let appID = Int64(appIDString), let item = await lookupService.lookup(appID: appID) {
            await MainActor.run {
                if let name = item.trackName?.nonEmptyOrNil {
                    cachedAppName = name
                }
            }
            if let bytes = item.fileSizeBytes, let parsed = Int64(bytes) {
                return parsed
            }
        }
        return nil
    }
    
    func ensureSuggestedFilename() {
        if let cached = cachedAppName?.nonEmptyOrNil {
            suggestedFilename = FilenameHelper.sanitize(name: cached)
            return
        }
        if let bundle = bundleIdentifier.nonEmptyOrNil {
            suggestedFilename = FilenameHelper.filename(fromBundleID: bundle)
            return
        }
        if let appID = appIDString.nonEmptyOrNil {
            suggestedFilename = FilenameHelper.filename(fromAppID: appID)
            return
        }
        suggestedFilename = FilenameHelper.defaultFilename
    }
    
    private func updateSuggestedFilename() {
        ensureSuggestedFilename()
    }
    
    func deleteDownloadedFile() {
        guard let fileURL = lastDownloadedURL else {
            activeError = .serverError(404, localizationManager.strings.fileNotFound)
            return
        }
        
        do {
            try fileManagerService.deleteFile(at: fileURL)
            lastDownloadedURL = nil
            statusMessage = localizationManager.strings.fileDeleted
            clearError()
        } catch {
            handleError(error)
        }
    }
}
