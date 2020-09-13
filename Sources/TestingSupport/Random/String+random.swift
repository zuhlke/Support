import Foundation

extension String {
    
    public static func random() -> String {
        UUID.random().uuidString
    }
    
}
