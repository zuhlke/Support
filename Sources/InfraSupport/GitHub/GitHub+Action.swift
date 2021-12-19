import Foundation
import YAMLBuilder

protocol GitHubActionRunSpecification {
    var yamlNode: YAML.Node { get }
}

extension GitHub {
    
    /// Represents a GitHub action.
    ///
    /// Action syntax is documented [here](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions).
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
        var runs: GitHubActionRunSpecification
    }
    
}

extension GitHub.Action {
    
    init(_ name: String, description: () -> String, runs: () -> Method) {
        self.init(name: name, description: description(), runs: runs())
    }
    
}

extension GitHub.Action {
    
    var yamlRepresentation: YAML {
        YAML {
            "name".is(.text(name))
            "description".is(.text(description))
            
            "runs".is(runs.yamlNode)
        }
    }
    
}

extension GitHub.Action.Method: GitHubActionRunSpecification {
    
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
