import Foundation

struct CombinedDifference<Element: Equatable>: Equatable {
    enum Change: Equatable {
        case none
        case added
        case removed
    }
    
    var element: Element
    var change: Change
}

extension BidirectionalCollection where Element: Equatable {
    /// Returns an array of all elements from receiver and another collection, along with how they have changed from one to another.
    func combinedDifference<C>(from other: C) -> [CombinedDifference<Element>] where C: BidirectionalCollection, C.Element == Self.Element {
        let difference = difference(from: other)
        
        var lines = other.map { CombinedDifference(element: $0, change: .none) }
        
        var indexes = (0 ..< lines.count).map { $0 }
        for removal in difference.removals.reversed() {
            indexes.remove(at: removal.offset)
            lines[removal.offset].change = .removed
        }
        
        for change in difference.insertions {
            let indexToInsert = (change.offset < indexes.count) ? indexes[change.offset] : lines.count
            lines.insert(CombinedDifference(element: change.element, change: .added), at: indexToInsert)
            for i in 0 ..< indexes.count {
                if indexes[i] >= indexToInsert {
                    indexes[i] += 1
                }
            }
            indexes.insert(indexToInsert, at: change.offset)
        }
        return lines
    }
}

private extension CollectionDifference.Change {
    var offset: Int {
        switch self {
        case .insert(let offset, _, _), .remove(let offset, _, _):
            offset
        }
    }
    
    var element: ChangeElement {
        switch self {
        case .insert(_, let element, _), .remove(_, let element, _):
            element
        }
    }
    
}
