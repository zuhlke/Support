import Foundation
import YAMLBuilder

extension GitHub {
    
    /// Represents a GitHub action.
    public struct Action {
        struct CompositeRunStep {
            var name: String
            var shell: String
            var run: String
        }

        enum Method {
            case composite(steps: [CompositeRunStep])
        }

        var name: String
        var description: String
        var method: Method
    }
    
}

extension GitHub.Action {
    
    var yamlRepresentation: YAML {
        YAML {
            "name".is(.text(name))
            "description".is(.text(description))
            
            "runs".is(method.yamlNode)
        }
    }
    
}

private extension GitHub.Action.Method {
    
    var yamlNode: YAML.Node {
        switch self {
        case .composite(let steps):
            return YAML.Node {
                "using".is("composite")
                
                "steps".is {
                    YAML.Node {
                        for step in steps {
                            "name".is(.text(step.name))
                            "run".is(.text(step.run))
                            "shell".is(.text(step.shell))
                        }
                    }
                }
            }
        }
    }
    
}
