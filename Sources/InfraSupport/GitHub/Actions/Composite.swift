import Foundation
import Support
import YAMLBuilder

public typealias Composite = GitHub.Action.Composite

extension GitHub.Action {
    
    public struct Composite {
        
        public struct Step {
            var name: String?
            var id: String?
            
            var shell: String
            var run: String
            
            var environment: [String: String] = [:]
        }
        
        var steps: [Step]
        
    }
    
}

extension Composite: GitHub.Action.Run {
    
    public init(@CompositeStepsBuilder steps: () -> [Step]) {
        self.init(steps: steps())
    }
    
    public var yamlDescription: YAML.Map {
        "using".is("composite")
        
        "steps".is {
            for step in steps {
                .map(step.yamlDescription)
            }
        }
    }
    
}

extension Composite.Step {

    public init(_ name: String? = nil, shell: String, run: () -> String) {
        self.init(name: name, shell: shell, run: run())
    }
    
    public func id(_ id: String) -> Composite.Step {
        mutating(self) {
            $0.id = id
        }
    }
    
    public func environment(_ environment: [String: String]) -> Composite.Step {
        mutating(self) {
            $0.environment = environment
        }
    }
    
    @NodeMappingBuilder
    public var yamlDescription: YAML.Map {
        if let name = name {
            "name".is(.text(name))
        }
        
        if let id = id {
            "id".is(.text(id))
        }
        
        if !environment.isEmpty {
            "env".is {
                for (key, value) in environment.sorted(by: { $0.key < $1.key }) {
                    key.is(.text(value))
                }
            }
        }
        
        "run".is(.text(run))
        "shell".is(.text(shell))
    }

}

@resultBuilder
public class CompositeStepsBuilder: ArrayBuilder<Composite.Step> {
    
    public static func buildFinalResult(_ steps: [Composite.Step]) -> [Composite.Step] {
        steps
    }
}
