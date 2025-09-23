import SwiftUI

extension String {
    func highlighted(matching queries: [String], highlightColor: Color = .yellow.opacity(0.4)) -> AttributedString {
        var attributed = AttributedString(self)
        let lowerSelf = self.lowercased()
        
        for query in queries where !query.isEmpty {
            let lowerQuery = query.lowercased()
            var searchRange = lowerSelf.startIndex..<lowerSelf.endIndex
            
            while let range = lowerSelf.range(of: lowerQuery, options: .caseInsensitive, range: searchRange) {
                if let attrRange = Range(range, in: attributed) {
                    attributed[attrRange].backgroundColor = UIColor(highlightColor)
                }
                searchRange = range.upperBound..<lowerSelf.endIndex
            }
        }
        
        return attributed
    }
}
