import Foundation
import Combine

@MainActor
final class VersionMetadataViewModel: BaseViewModel {
    @Published var versionID: String = ""
    @Published var bundleID: String = ""
    @Published var appIDString: String = ""
    @Published var displayVersion: String?
    @Published var releaseDate: String?
    @Published var isFetching: Bool = false
    
    func fetchMetadata() {
        guard ValidationHelpers.isValidVersionID(versionID) else {
            activeError = .serverError(400, localizationManager.strings.versionIDRequiredError)
            return
        }
        
        guard ValidationHelpers.isValidAppIDOrBundleID(appID: appIDString, bundleID: bundleID) else {
            activeError = .serverError(400, localizationManager.strings.appIDOrBundleIDRequiredError)
            return
        }
        
        isFetching = true
        isLoading = true
        clearError()
        statusMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let appID = Int64(self.appIDString)
                let response = try await apiService.getVersionMetadata(
                    versionID: self.versionID,
                    bundleID: self.bundleID.isEmpty ? nil : self.bundleID,
                    appID: appID
                )
                
                if response.success {
                    self.displayVersion = response.displayVersion
                    self.releaseDate = response.releaseDate
                    self.statusMessage = self.localizationManager.strings.metadataFetched
                } else {
                    self.activeError = .serverError(500, self.localizationManager.strings.fetchMetadataFailed)
                }
            } catch {
                self.handleError(error)
            }
            
            self.isFetching = false
            self.isLoading = false
        }
    }
}
