import Foundation
import Combine

@MainActor
class BaseViewModel: ObservableObject {
    @Published var statusMessage: String?
    @Published var activeError: APIError?
    @Published var isLoading: Bool = false
    
    let apiService = APIService.shared
    let localizationManager = LocalizationManager.shared
    
    func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            activeError = apiError
        } else {
            activeError = .networkError(error)
        }
    }
    
    func resetLoadingState() {
        isLoading = false
        statusMessage = nil
    }
    
    func clearError() {
        activeError = nil
    }
}
