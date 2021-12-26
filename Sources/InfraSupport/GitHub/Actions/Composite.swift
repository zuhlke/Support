import Foundation
import Support
import YAMLBuilder

typealias Composite = GitHub.Action.Composite

public struct CompositeActionStep {
    var name: String?
    var id: String?
    
    var shell: String
    var run: String
    
    var environment: [String: String] = [:]
}

extension GitHub.Action {
    
    struct Composite {
        typealias Step = CompositeActionStep
        
        var steps: [Step]
        
    }
    
}

extension Composite: GitHub.Action.Run {
    
    init(@CompositeStepsBuilder steps: () -> [Step]) {
        self.init(steps: steps())
    }
    
    var yamlDescription: YAML.Map {
        "using".is("composite")
        
        "steps".is {
            for step in steps {
                .map(step.yamlDescription)
            }
        }
    }
    
}

extension Composite.Step {

    init(_ name: String? = nil, shell: String, run: () -> String) {
        self.init(name: name, shell: shell, run: run())
    }
    
    func id(_ id: String) -> Composite.Step {
        mutating(self) {
            $0.id = id
        }
    }
    
    func environment(_ environment: [String: String]) -> Composite.Step {
        mutating(self) {
            $0.environment = environment
        }
    }
    
    @NodeMappingBuilder
    var yamlDescription: YAML.Map {
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
class CompositeStepsBuilder: ArrayBuilder<Composite.Step> {
    
    static func buildFinalResult(_ steps: [Composite.Step]) -> [Composite.Step] {
        steps
    }
}
