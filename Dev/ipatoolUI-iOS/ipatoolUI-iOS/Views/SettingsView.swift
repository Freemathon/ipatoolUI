import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    // Security: Validate URL format
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        guard let scheme = url.scheme?.lowercased() else {
            return false
        }
        
        guard scheme == "http" || scheme == "https" else {
            return false
        }
        
        return url.host != nil
    }
    
    private var languageBinding: Binding<AppLanguage?> {
        Binding(
            get: { appState.preferences.language },
            set: { newValue in
                appState.preferences.language = newValue
            }
        )
    }
    
    private var localeBinding: Binding<String?> {
        Binding(
            get: { appState.preferences.selectedCountryCode },
            set: { newValue in
                appState.preferences.selectedCountryCode = newValue
            }
        )
    }
    
    var body: some View {
        Form {
            Section {
                TextField(appState.localizationManager.strings.apiBaseURL, text: Binding(
                    get: { appState.preferences.apiBaseURL },
                    set: { newValue in
                        // Security: Validate URL before saving
                        if isValidURL(newValue) {
                            appState.preferences.apiBaseURL = newValue
                        }
                    }
                ))
                .autocorrectionDisabled()
                .textContentType(.URL)
                .keyboardType(.URL)
                
                SecureField(appState.localizationManager.strings.apiKey, text: Binding(
                    get: { appState.preferences.apiKey },
                    set: { appState.preferences.apiKey = $0 }
                ))
                .autocorrectionDisabled()
            } header: {
                Text(appState.localizationManager.strings.serverSettings)
            } footer: {
                if !isValidURL(appState.preferences.apiBaseURL) && !appState.preferences.apiBaseURL.isEmpty {
                    Text("Invalid URL format. Please enter a valid HTTP/HTTPS URL.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section {
                Picker(appState.localizationManager.strings.languageLabel, selection: languageBinding) {
                    Text(appState.localizationManager.strings.autoSystem).tag(AppLanguage?.none)
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(AppLanguage?.some(lang))
                    }
                }
            } header: {
                Text(appState.localizationManager.strings.languageLabel)
            }
            
            Section {
                Picker(appState.localizationManager.strings.locale, selection: localeBinding) {
                    Text(appState.localizationManager.strings.autoSystemAccount).tag(String?.none)
                    ForEach(CountryCode.allCountries) { country in
                        Text("\(country.name) (\(country.currencySymbol))").tag(String?.some(country.code))
                    }
                }
                if let selectedCode = appState.preferences.selectedCountryCode,
                   let country = CountryCode.find(by: selectedCode) {
                    Text("\(appState.localizationManager.strings.selected) \(country.name) - \(country.currencySymbol)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(appState.localizationManager.strings.using) \(appState.effectiveCountryCode ?? appState.localizationManager.strings.unknown)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(appState.localizationManager.strings.currencyDisplay)
            }
            
            Section {
                Button(appState.localizationManager.strings.resetToDefault, role: .destructive) {
                    appState.preferences = Preferences.default
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(AppState())
        }
    }
}
