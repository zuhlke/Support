import Foundation

public enum Description {
    case string(String)
    case dictionary([String: Description])
    case array([Description])
    case jsonObject(Any)
    case null
}
