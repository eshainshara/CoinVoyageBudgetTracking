import SwiftUI
import Combine

struct RootView: View {
    @StateObject private var appState = AppState()
    @ObservedObject private var themeService = ThemeService.shared
    
    var body: some View {
        Group {
            if appState.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                if appState.shouldShowBrowser {
                    BrowserScreen()
                        .preferredColorScheme(themeService.currentTheme.colorScheme)
                } else {
                    MainTabView()
                        .preferredColorScheme(themeService.currentTheme.colorScheme)
                }
            }
        }
        .task {
            await appState.checkInitialState()
        }
    }
}

class AppState: ObservableObject {
    @Published var shouldShowBrowser = false
    @Published var isLoading = true
    let themeService = ThemeService.shared
    
    private let tokenService = TokenService.shared
    private let networkService = NetworkService.shared
    
    func checkInitialState() async {
        await MainActor.run {
            isLoading = true
        }
        
        if let token = tokenService.getToken(), !token.isEmpty {
            if let link = tokenService.getLink(), !link.isEmpty {
                await MainActor.run {
                    shouldShowBrowser = true
                    isLoading = false
                }
                return
            }
        }
        
        do {
            let response = try await networkService.fetchServerData()
            
            if response.contains("#") {
                let components = response.components(separatedBy: "#")
                if components.count == 2 {
                    let token = components[0]
                    let link = components[1]
                    
                    tokenService.saveToken(token)
                    tokenService.saveLink(link)
                    
                    await MainActor.run {
                        shouldShowBrowser = true
                        isLoading = false
                    }
                    return
                }
            }
            
            await MainActor.run {
                shouldShowBrowser = false
                isLoading = false
            }
        } catch {
            await MainActor.run {
                shouldShowBrowser = false
                isLoading = false
            }
        }
    }
}

