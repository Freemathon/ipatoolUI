import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "app.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("ipatool UI")
                            .font(.title2.bold())
                        
                        Text(appState.localizationManager.strings.iosVersion)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(appState.localizationManager.strings.appDescription)
                        .font(.body)
                    
                    Text(appState.localizationManager.strings.macVersionFeatures)
                        .font(.body)
                        .padding(.top, 4)
                }
            } header: {
                Text(appState.localizationManager.strings.overview)
            }
            
            Section {
                Link("ipatool-server", destination: URL(string: "https://github.com/majd/ipatool")!)
            } header: {
                Text(appState.localizationManager.strings.links)
            }
        }
        .formStyle(.grouped)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AboutView()
        }
    }
}
