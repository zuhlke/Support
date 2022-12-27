import Foundation

enum Description: Hashable {
    case string(String)
    case dictionary([String: Description])
    case array([Description])
    case set(Set<Description>)
    case null
}

extension Description: CustomDescriptionConvertible {
    var structuredDescription: Description {
        self
    }
}

extension Description {
    
    init(for value: Any) {
        if let value = value as? CustomDescriptionConvertible {
            self = value.structuredDescription
        } else {
            self.init(mirroring: value)
        }
    }
    
    private init(mirroring subject: Any) {
        let mirror = Mirror(reflecting: subject)
        switch mirror.displayStyle ?? .struct {
        case .struct where !mirror.children.isEmpty,
             .class where !mirror.children.isEmpty:
            var dictionary = [String: Description]()
            var instanceMirror: Mirror? = mirror
            while instanceMirror != nil {
                instanceMirror?.children.forEach { key, value in
                    if let key = key {
                        dictionary[key] = Description(for: value)
                    }
                }
                instanceMirror = instanceMirror?.superclassMirror
            }

            self = .dictionary(dictionary)
            
        case .optional:
            var value: Any?
            mirror.children.forEach { _, child in
                value = child
            }
            if let value = value {
                self = Description(for: value)
            } else {
                self = .null
            }
            
        case .collection:
            let array = mirror.children.map { _, child in
                Description(for: child)
            }
            self = .array(array)
            
        case .set:
            let children = mirror.children.lazy
                .map { _, child in
                    Description(for: child)
                }
            self = .set(Set(children))
            
        case .dictionary:
            var dictionary = [String: Description]()
            mirror.children.forEach { _, child in
                var key: String?
                var value: Any?
                Mirror(reflecting: child).children.forEach { label, subchild in
                    switch label {
                    case "key":
                        key = subchild as? String
                    case "value":
                        value = subchild
                    default:
                        break
                    }
                }
                if let key = key, let value = value {
                    dictionary[key] = Description(for: value)
                }
            }
            self = .dictionary(dictionary)
            
        default:
            self = .string("\(subject)")
        }
    }
    
}

func describe(_ value: Any) {
    print(description(for: value))
}

func description(for subject: Any) -> String {
    let object = Description(for: subject)
    switch object {
    case .dictionary, .array, .set:
        let json = try! JSONSerialization.data(withJSONObject: object.jsonObject, options: [.prettyPrinted, .sortedKeys])
        return String(data: json, encoding: .utf8)!
    case .string(let string):
        return string
    case .null:
        return "<Null>"
    }
}

private extension Description {
    var jsonObject: Any {
        switch self {
        case .string(let value):
            return value
        case .dictionary(let value):
            return value.mapValues { $0.jsonObject }
        case .array(let value):
            return value.map(\.jsonObject)
        case .set(let value):
            return value
                .sorted { "\($0)" < "\($1)" } // doesn’t matter as long as it’s predictable
                .map(\.jsonObject)
        case .null:
            return NSNull()
        }
    }
}
