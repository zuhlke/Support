import Foundation

public class LazyDescription: CustomDescriptionConvertible {
    private var load: () -> Any
    
    public private(set) lazy var structuredDescription: Description = .init(for: load())
    
    public init(for load: @escaping @autoclosure () -> Any) {
        self.load = load
    }
    
}
