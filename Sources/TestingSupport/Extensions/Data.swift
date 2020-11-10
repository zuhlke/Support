import Foundation

extension Data {
    
    public func normalizingJSON() -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: self, options: []) else {
            return self
        }

        return try! JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
    }
    
}

extension Data: CustomDescriptionConvertible {
    var descriptionObject: Description {
        if let string = String(data: self, encoding: .utf8) {
            return .string(string)
        } else {
            return .string(base64EncodedString())
        }
    }
}
