import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var theme: AppTheme {
        didSet {
            ThemeService.shared.currentTheme = theme
        }
    }
    
    init() {
        self.theme = ThemeService.shared.currentTheme
    }
}

