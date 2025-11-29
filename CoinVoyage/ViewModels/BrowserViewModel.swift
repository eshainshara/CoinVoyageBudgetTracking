import Foundation
import Combine

class BrowserViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var currentAddress: String
    
    private let tokenService = TokenService.shared
    var hasLoadedInitially = false
    
    init() {
        self.currentAddress = tokenService.getLink() ?? ""
    }
    
    func loadPage() {
        if !hasLoadedInitially {
            isLoading = true
        }
    }
    
    func didFinishInitialLoad() {
        hasLoadedInitially = true
        isLoading = false
    }
    
    func didStartNavigation() {
        if !hasLoadedInitially {
            isLoading = true
        }
    }
}

