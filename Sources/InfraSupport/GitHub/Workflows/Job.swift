import Foundation
import YAMLBuilder
import Support

public typealias Job = GitHub.Workflow.Job

public protocol JobStepMethod {
    
    @NodeMappingEntryBuilder
    var yamlRepresentation: [(String, YAML.Node)] { get }
    
}

extension JobStepMethod where Self == Job.Step.ActionMethod {
    
    public static func action(_ reference: String, inputs: [String: String] = [:]) -> Self {
        Job.Step.ActionMethod(reference: reference, inputs: inputs)
    }
    
}

extension JobStepMethod where Self == Job.Step.ScriptMethod {
    
    public static func run(_ script: String) -> Self {
        Job.Step.ScriptMethod(script: script)
    }
    
}

extension GitHub.Workflow {
    public struct Job {
        public struct Step {
            public struct ActionMethod {
                var reference: String
                var inputs: [String: String]
            }
            public struct ScriptMethod {
                var script: String
            }
            
            var name: String
            var workingDirectory: String?
            var environment: [String: String] = [:]
            var method: JobStepMethod
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
    
    init<M: JobStepMethod>(_ name: String, method: () -> M) {
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
            
            method.yamlRepresentation
        }
    }
    
}

extension Job.Step.ActionMethod: JobStepMethod {
    
    @NodeMappingEntryBuilder
    public var yamlRepresentation: [(String, YAML.Node)] {
        "uses".is(.text(reference))
        if !inputs.isEmpty {
            "with".is {
                for (key, value) in inputs.sorted(by: { $0.key < $1.key }) {
                    key.is(.text(value))
                }
            }
        }
    }
}

extension Job.Step.ScriptMethod: JobStepMethod {
    
    @NodeMappingEntryBuilder
    public var yamlRepresentation: [(String, YAML.Node)] {
        "run".is(.text(script))
    }
}

@resultBuilder
public class JobStepsBuilder: ArrayBuilder<Job.Step> {
    
    public static func buildFinalResult(_ steps: [Job.Step]) -> [Job.Step] {
        steps
    }
}


@resultBuilder
public class NodeMappingEntryBuilder: ArrayBuilder<(String, YAML.Node)> {
    
    public static func buildFinalResult(_ pairs: [(String, YAML.Node)]) -> [(String, YAML.Node)] {
        pairs
    }
}