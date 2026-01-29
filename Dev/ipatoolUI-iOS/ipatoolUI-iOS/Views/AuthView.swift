import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section {
                TextField(appState.localizationManager.strings.email, text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                
                SecureField(appState.localizationManager.strings.password, text: $viewModel.password)
                    .textContentType(.password)
                
                TextField(appState.localizationManager.strings.twoFactorAuthCodeOptional, text: $viewModel.authCode)
                    .textContentType(.oneTimeCode)
                    .autocorrectionDisabled()
            } header: {
                Text(appState.localizationManager.strings.appleID)
            }
            
            Section {
                Button(action: signIn) {
                    HStack {
                        if viewModel.isWorking {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(appState.localizationManager.strings.signIn)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isWorking || viewModel.email.isEmpty || viewModel.password.isEmpty)
                
                HStack {
                    Button(appState.localizationManager.strings.accountInfo, action: fetchInfo)
                        .disabled(viewModel.isWorking)
                    Button(appState.localizationManager.strings.deleteAuth, role: .destructive, action: revoke)
                        .disabled(viewModel.isWorking)
                }
            }
            
            Section {
                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                if let error = viewModel.activeError {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } header: {
                Text(appState.localizationManager.strings.status)
            }
        }
        .formStyle(.grouped)
        .task {
            viewModel.bootstrap()
        }
    }
    
    private func signIn() {
        viewModel.login()
    }
    
    private func fetchInfo() {
        Task {
            await viewModel.fetchInfo()
        }
    }
    
    private func revoke() {
        viewModel.revoke()
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthView(viewModel: AuthViewModel())
        }
    }
}
