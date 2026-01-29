import Foundation
import Combine

@MainActor
final class PurchaseViewModel: BaseViewModel {
    @Published var bundleID: String = ""
    @Published var isPurchasing: Bool = false
    
    func purchase() {
        guard ValidationHelpers.isValidBundleID(bundleID) else {
            activeError = .serverError(400, localizationManager.strings.bundleIDRequired)
            return
        }
        
        isPurchasing = true
        isLoading = true
        clearError()
        statusMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await apiService.purchase(bundleID: self.bundleID)
                
                if response.success {
                    self.statusMessage = response.message ?? "\(self.bundleID) \(self.localizationManager.strings.purchaseSuccess)"
                } else {
                    self.activeError = .serverError(500, self.localizationManager.strings.purchaseFailed)
                }
            } catch {
                self.handleError(error)
            }
            
            self.isPurchasing = false
            self.isLoading = false
        }
    }
}
