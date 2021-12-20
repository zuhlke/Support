import Foundation
import YAMLBuilder

public typealias Job = GitHub.Workflow.Job

extension GitHub.Workflow {
    public struct Job {
        struct Step {
            enum Method {
                case none
                case action(String, inputs: [String: String])
                case run(String)

                static func action(_ name: String) -> Method {
                    .action(name, inputs: [:])
                }
            }
            
            var name: String
            var workingDirectory: String?
            var environment: [String: String] = [:]
            var method: Method = .none
        }
        
        var id: String
        var name: String
        var needs: [String] = []
        var runsOn: String
        var steps: [Step]
    }
}

extension GitHub.Workflow.Job {
    
    var content: YAML.Node {
        YAML.Node {
            "name".is(.text(name))
            if !needs.isEmpty {
                "needs".is {
                    for need in needs {
                        need
                    }
                }
            }
            "runs-on".is(.text(runsOn))
            
            "steps".is {
                for step in steps {
                    step.content
                }
            }
        }
    }
    
}

private extension GitHub.Workflow.Job.Step {
    
    var content: YAML.Node {
        YAML.Node {
            "name".is(.text(name))
            
            if let workingDirectory = workingDirectory {
                "working-directory".is(.text(workingDirectory))
            }
            
            if !environment.isEmpty {
                "env".is {
                    for (key, value) in environment.sorted(by: { $0.key < $1.key }) {
                        key.is(.text(value))
                    }
                }
            }
            
            switch method {
            case .none:
                "none".is("TBC")
            case .action(let ref, let inputs):
                "uses".is(.text(ref))
                if !inputs.isEmpty {
                    "with".is {
                        for (key, value) in inputs.sorted(by: { $0.key < $1.key }) {
                            key.is(.text(value))
                        }
                    }
                }
            case .run(let script):
                "run".is(.text(script))
            }
        }
    }
    
}
