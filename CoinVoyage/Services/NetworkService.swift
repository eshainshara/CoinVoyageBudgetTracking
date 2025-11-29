import Foundation
import UIKit
import AppsFlyerLib
import Darwin

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private func getDeviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        var identifier = ""
        for child in machineMirror.children {
            if let value = child.value as? Int8, value != 0 {
                let scalar = UnicodeScalar(UInt8(bitPattern: value))
                identifier.append(Character(scalar))
            }
        }
        return identifier.lowercased()
    }
    
    func fetchServerData() async throws -> String {
        let osVersion = UIDevice.current.systemVersion
        let fullLanguage = Locale.preferredLanguages.first ?? "en"
        let language = fullLanguage.components(separatedBy: "-").first ?? "en"
        let deviceModel = getDeviceModelIdentifier()
        let country = Locale.current.region?.identifier ?? "US"
        let appsId = AppsFlyerLib.shared().getAppsFlyerUID()
        
        let baseAddress = "https://gtappinfo.site/ios-coinvoyage-budgettracking/server.php"
        var components = URLComponents(string: baseAddress)!
        components.queryItems = [
            URLQueryItem(name: "p", value: "Bs2675kDjkb5Ga"),
            URLQueryItem(name: "os", value: osVersion),
            URLQueryItem(name: "lng", value: language),
            URLQueryItem(name: "devicemodel", value: deviceModel),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "appsflyerid", value: appsId)
        ]
        
        guard let endpoint = components.endpoint else {
            throw NetworkError.invalidEndpoint
        }
        
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.invalidResponse
        }
        
        return responseString
    }
}

extension URLComponents {
    var endpoint: URL? {
        return self.url
    }
}

enum NetworkError: Error {
    case invalidEndpoint
    case invalidResponse
}

