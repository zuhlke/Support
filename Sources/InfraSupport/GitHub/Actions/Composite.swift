import Foundation
import YAMLBuilder

public typealias Composite = GitHub.Action.Composite

extension GitHub.Action {
    
    public struct Composite: GitHub.Action.Run {
        
        struct Step {
            var name: String
            var shell: String
            var run: String
        }
        
        var steps: [Step]
        
        public var yamlNode: YAML.Node {
            YAML.Node {
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
