import SwiftUI

struct DownloadView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: DownloadViewModel
    @State private var showShareSheet = false
    
    private static let sizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter
    }()
    
    init(viewModel: DownloadViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section {
                TextField(appState.localizationManager.strings.appID, text: $viewModel.appIDString)
                
                TextField(appState.localizationManager.strings.bundleID, text: $viewModel.bundleIdentifier)
                    .autocorrectionDisabled()
                
                TextField(appState.localizationManager.strings.externalVersionIDOptional, text: $viewModel.externalVersionID)
                    .autocorrectionDisabled()
            } header: {
                Text(appState.localizationManager.strings.targetApp)
            }
            
            Section {
                Toggle(appState.localizationManager.strings.autoPurchaseLicense, isOn: $viewModel.shouldAutoPurchase)
            } header: {
                Text(appState.localizationManager.strings.options)
            }
            
            Section {
                Button(action: download) {
                    HStack {
                        if viewModel.isDownloading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Label(appState.localizationManager.strings.downloadIPA, systemImage: "arrow.down.circle")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isDownloading || !validateInput())
                
                if viewModel.isDownloading {
                    VStack(alignment: .leading, spacing: 8) {
                        if let expected = viewModel.expectedBytes {
                            ProgressView(value: Double(viewModel.downloadedBytes), total: Double(expected))
                        } else {
                            ProgressView()
                        }
                        Text(progressLabel())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
                
                if let fileURL = viewModel.lastDownloadedURL, !viewModel.isDownloading {
                    HStack(spacing: 12) {
                        Button(action: { showShareSheet = true }) {
                            Label(appState.localizationManager.strings.shareFile, systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button(role: .destructive, action: {
                            viewModel.deleteDownloadedFile()
                        }) {
                            Label(appState.localizationManager.strings.deleteFile, systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                    .sheet(isPresented: $showShareSheet, onDismiss: {
                        if appState.preferences.deleteIPAAfterShare ?? false {
                            viewModel.deleteLastDownloadedFileAfterShare()
                        }
                        viewModel.refreshDownloadedFilesList()
                    }) {
                        ShareSheet(items: [fileURL])
                    }
                }
            }
            
            Section {
                ForEach(viewModel.downloadedFileURLs, id: \.path) { url in
                    HStack {
                        Text(url.lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button(role: .destructive) {
                            viewModel.deleteFile(at: url)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                if !viewModel.downloadedFileURLs.isEmpty {
                    Button(role: .destructive, action: { viewModel.deleteAllDownloadedFiles() }) {
                        Label(appState.localizationManager.strings.deleteAll, systemImage: "trash.fill")
                    }
                }
            } header: {
                Text(appState.localizationManager.strings.downloadedFiles)
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
        .task {
            viewModel.ensureSuggestedFilename()
        }
        .onAppear {
            viewModel.refreshDownloadedFilesList()
        }
    }
    
    private func download() {
        viewModel.download()
    }
    
    private func validateInput() -> Bool {
        ValidationHelpers.isValidAppIDOrBundleID(appID: viewModel.appIDString, bundleID: viewModel.bundleIdentifier)
    }
    
    private func progressLabel() -> String {
        let downloaded = Self.sizeFormatter.string(fromByteCount: viewModel.downloadedBytes)
        if let total = viewModel.expectedBytes {
            let totalString = Self.sizeFormatter.string(fromByteCount: total)
            return "\(downloaded) / \(totalString)"
        }
        return "\(downloaded) \(appState.localizationManager.strings.downloaded)"
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DownloadView(viewModel: DownloadViewModel())
                .environmentObject(AppState())
        }
    }
}
