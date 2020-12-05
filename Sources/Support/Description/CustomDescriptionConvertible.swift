import Foundation

public protocol CustomDescriptionConvertible {
    var structuredDescription: Description { get }
}

extension Data: CustomDescriptionConvertible {
    public var structuredDescription: Description {
        if let string = String(data: self, encoding: .utf8) {
            return .string(string)
        } else {
            return .dictionary([
                "base64Encoded": .string(base64EncodedString()),
            ])
        }
    }
}
