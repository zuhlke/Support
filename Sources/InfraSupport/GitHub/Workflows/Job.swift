import Foundation
import YAMLBuilder
import Support

public typealias Job = GitHub.Workflow.Job

extension GitHub.Workflow {
    public struct Job {
        public struct Step {
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
        var runsOn: String
        var needs: [String] = []
        var steps: [Step]
    }
}

extension GitHub.Workflow.Job {
    
    public init(
        id: String,
        name: String,
        runsOn: String,
        needs: [String] = [],
        @JobStepsBuilder steps: () -> [Step]
    ) {
        self.init(
            id: id,
            name: name,
            runsOn: runsOn,
            needs: needs,
            steps: steps()
        )
    }
    
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


extension Job.Step {
    
    init(_ name: String, method: () -> Method) {
        self.init(name: name, method: method())
    }
    
    public func workingDirectory(_ workingDirectory: String) -> Job.Step {
        mutating(self) {
            $0.workingDirectory = workingDirectory
        }
    }
    
    public func environment(_ environment: [String: String]) -> Job.Step {
        mutating(self) {
            $0.environment = environment
        }
    }
    
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

@resultBuilder
public class JobStepsBuilder: ArrayBuilder<Job.Step> {
    
    public static func buildFinalResult(_ steps: [Job.Step]) -> [Job.Step] {
        steps
    }
}
