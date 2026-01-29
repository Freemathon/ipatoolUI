import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section {
                TextField(appState.localizationManager.strings.searchTerm, text: $viewModel.term)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit(search)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(appState.localizationManager.strings.limit): \(Int(viewModel.limit))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(value: $viewModel.limit, in: 1...25, step: 1)
                }
                
                Button(action: search) {
                    HStack {
                        if viewModel.isSearching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(appState.localizationManager.strings.search)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSearching || viewModel.term.trimmingCharacters(in: .whitespaces).isEmpty)
            } header: {
                Text(appState.localizationManager.strings.search)
            }
            
            if let feedback = viewModel.feedback {
                Section {
                    Text(feedback)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
            
            if !viewModel.results.isEmpty {
                Section {
                    ForEach(viewModel.results) { app in
                        AppRowView(app: app, viewModel: viewModel)
                            .environmentObject(appState)
                    }
                } header: {
                    Text(appState.localizationManager.strings.searchResults)
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private func search() {
        // Use selected country code, or effectiveCountryCode (account > system) for search
        let countryCode = appState.preferences.selectedCountryCode ?? appState.effectiveCountryCode ?? appState.accountCountryCode
        viewModel.search(countryCode: countryCode)
    }
}

struct AppRowView: View {
    let app: AppInfo
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject private var appState: AppState
    @State private var showPurchaseConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            iconView(for: viewModel.artworkURL(for: app))
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(app.name ?? appState.localizationManager.strings.unknown)
                        .font(.headline)
                    Spacer()
                    if let price = app.price {
                        // Use selected country code, or the country code from the search, or fallback to effectiveCountryCode
                        let countryCode = appState.preferences.selectedCountryCode ?? viewModel.lastUsedCountryCode ?? appState.effectiveCountryCode
                        Text(CurrencyFormatter.formatPrice(price, countryCode: countryCode))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if let bundleID = app.bundleID {
                    Text(bundleID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = bundleID
                            }) {
                                Label(appState.localizationManager.strings.copy, systemImage: "doc.on.doc")
                            }
                        }
                }
                
                HStack {
                    if let version = app.version {
                        Text("\(appState.localizationManager.strings.version) \(version)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = version
                                }) {
                                    Label(appState.localizationManager.strings.copyVersion, systemImage: "doc.on.doc")
                                }
                            }
                    }
                    
                    Spacer()
                    
                    if viewModel.isPurchased(app: app) {
                        Label(appState.localizationManager.strings.purchased, systemImage: "checkmark.circle.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    } else if viewModel.isCheckingPurchase(for: app) {
                        ProgressView()
                            .controlSize(.small)
                    } else if app.bundleID != nil {
                        Button(appState.localizationManager.strings.purchaseButton) {
                            showPurchaseConfirmation = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .task {
            await viewModel.ensurePurchaseStatus(for: app)
        }
        .confirmationDialog(appState.localizationManager.strings.purchase, isPresented: $showPurchaseConfirmation) {
            Button(appState.localizationManager.strings.purchaseButton, role: .none) {
                viewModel.purchase(bundleID: app.bundleID)
            }
            Button(appState.localizationManager.strings.cancel, role: .cancel) {}
        } message: {
            Text("\(app.name ?? appState.localizationManager.strings.unknown) \(appState.localizationManager.strings.purchaseButton)")
        }
    }
    
    private func iconView(for url: URL?) -> some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        placeholderIcon
                    @unknown default:
                        placeholderIcon
                    }
                }
            } else {
                placeholderIcon
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var placeholderIcon: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.secondary.opacity(0.2))
            .overlay {
                Image(systemName: "app.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }
    
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView(viewModel: SearchViewModel())
                .environmentObject(AppState())
        }
    }
}
