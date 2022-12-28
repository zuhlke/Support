import XCTest
import YAMLBuilder

public extension XCUIElementSnapshotProviding {
    
    /// A readable representation of the UI.
    ///
    /// - Note: The representation format is not guaranteed to be stable across releases of the library, and therefore is not recommended for structural snapshot testing.
    var snapshotDescription: String {
        get throws {
            YAMLEncoder().encode(YAML(root: try snapshot().node))
        }
    }
    
}

private extension XCUIElementSnapshot {
    
    var node: YAML.Map {
        YAML.Map {
            "type".is(.text(elementType.description))
            if !title.isEmpty {
                "title".is(.text(title))
            }
            if !label.isEmpty {
                "title".is(.text(label))
            }
            if let value {
                "value".is(.text("\(value)"))
            }
            if let placeholderValue {
                "placeholderValue".is(.text("\(placeholderValue)"))
            }
            if !children.isEmpty {
                "children".is {
                    for child in children {
                        .map(child.node)
                    }
                }
            }
        }
    }
    
}
