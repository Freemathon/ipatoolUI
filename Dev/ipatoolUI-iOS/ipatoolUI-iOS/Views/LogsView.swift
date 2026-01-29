import SwiftUI

struct LogsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var logs: [String] = []
    
    var body: some View {
        Form {
            Section {
                if logs.isEmpty {
                    Text(appState.localizationManager.strings.noLogsYet)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(logs.enumerated()), id: \.offset) { index, log in
                        Text(log)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
            } header: {
                Text(appState.localizationManager.strings.logs)
            }
            
            Section {
                Button(appState.localizationManager.strings.clearLogs, role: .destructive) {
                    logs.removeAll()
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct LogsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LogsView()
        }
    }
}
