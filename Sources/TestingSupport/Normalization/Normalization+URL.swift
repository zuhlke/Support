import Foundation

extension Normalization<URL> {
    
    /// Normalises the URL for the purpose of testing.
    public static let normalizingForTesting = Normalization {
        guard var components = URLComponents(url: $0, resolvingAgainstBaseURL: false) else { return $0 }
        
        components.queryItems = components.queryItems.map {
            $0.sorted { $0.sortingValue < $1.sortingValue }
        }
        
        return components.url!
    }
    
}

private extension URLQueryItem {
    
    var sortingValue: String {
        "\(name)=\(value ?? "")"
    }
    
}
