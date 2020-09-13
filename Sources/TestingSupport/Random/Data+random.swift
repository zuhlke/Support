import Foundation

extension Data {
    
    public static func random() -> Data {
        String.random().data(using: .utf8)!
    }
    
}
