import XCTest
import YAMLBuilder

public extension XCUIElementSnapshotProviding {
    
    var snapshotRepresentation: String {
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
