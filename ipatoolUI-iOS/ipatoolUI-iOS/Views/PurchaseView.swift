import SwiftUI

struct PurchaseView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: PurchaseViewModel
    
    init(viewModel: PurchaseViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section {
                TextField(appState.localizationManager.strings.bundleID, text: $viewModel.bundleID)
                    .autocorrectionDisabled()
            } header: {
                Text(appState.localizationManager.strings.appInfo)
            } footer: {
                Text(appState.localizationManager.strings.enterBundleIDToPurchase)
            }
            
            Section {
                Button(action: purchase) {
                    HStack {
                        if viewModel.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(appState.localizationManager.strings.purchaseButton)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isPurchasing || viewModel.bundleID.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            if let status = viewModel.statusMessage {
                Section {
                    Text(status)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(appState.localizationManager.strings.status)
                }
            }
            
            if let error = viewModel.activeError {
                Section {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                } header: {
                    Text(appState.localizationManager.strings.error)
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private func purchase() {
        viewModel.purchase()
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PurchaseView(viewModel: PurchaseViewModel())
        }
    }
}
