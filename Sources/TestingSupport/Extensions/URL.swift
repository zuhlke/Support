import Foundation

extension URL {
    
    public func normalizingForTesting() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        
        components.queryItems = components.queryItems.map {
            $0.sorted { $0.sortingValue < $1.sortingValue }
        }
        
        return components.url ?? self
    }
    
}

private extension URLQueryItem {
    
    var sortingValue: String {
        "\(name)=\(value ?? "")"
    }
    
}
