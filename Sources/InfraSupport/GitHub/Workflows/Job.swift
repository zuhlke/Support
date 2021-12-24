import Foundation
import Support
import YAMLBuilder

public typealias Job = GitHub.Workflow.Job

public protocol JobStepMethod {
    
    @NodeMapElementBuilder
    var yamlRepresentation: [YAML.Map.Element] { get }
    
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
        
        public struct Runner: ExpressibleByStringLiteral {
            var label: String
            var comment: String?
            
            public init(_ label: String) {
                self.label = label
            }
            
            public init(stringLiteral label: String) {
                self.label = label
            }
        }
        
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
            var condition: String?
            var environment: [String: String] = [:]
            var method: JobStepMethod
        }
        
        var id: String
        var name: String
        var runsOn: Runner
        var needs: [String] = []
        var steps: [Step]
    }
}

extension GitHub.Workflow.Job {
    
    public init(
        id: String,
        name: String,
        runsOn: Runner,
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
            "runs-on".is(.text(runsOn.label))
                .comment(runsOn.comment)
            
            "steps".is {
                for step in steps {
                    step.content
                }
            }
        }
    }
    
}

@dynamicMemberLookup
public struct InputProvider<Inputs: GitHubLocalActionParameterSet> {
    var inputs = Inputs()
    
    fileprivate var inputValues: [String: String] = [:]
    
    public subscript<Wrapped>(dynamicMember keyPath: KeyPath<Inputs, ActionInput<Wrapped>>) -> String? {
        get {
            inputValues[inputs[keyPath: keyPath].id]
        }
        set {
            inputValues[inputs[keyPath: keyPath].id] = newValue
        }
    }
}

extension Job.Step {
    
    public init<M: JobStepMethod>(_ name: String, method: () -> M) {
        self.init(name: name, method: method())
    }
    
    public init<Action>(action: Action) where Action: GitHubLocalAction, Action.Inputs == EmptyGitHubLocalActionParameterSet {
        self.init(action.name) {
            .action(".github/actions/\(action.id)")
        }
    }
    
    public init<Action>(action: Action, with inputs: (inout InputProvider<Action.Inputs>) -> ()) where Action: GitHubLocalAction {
        var provider = InputProvider<Action.Inputs>()
        inputs(&provider)
        self.init(action.name) {
            .action(".github/actions/\(action.id)", inputs: provider.inputValues)
        }
    }
    
    public func workingDirectory(_ workingDirectory: String?) -> Job.Step {
        mutating(self) {
            $0.workingDirectory = workingDirectory
        }
    }
    
    public func condition(_ condition: String?) -> Job.Step {
        mutating(self) {
            $0.condition = condition
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
            
            if let condition = condition {
                "if".is(.text(condition))
            }
            
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
    
    @NodeMapElementBuilder
    public var yamlRepresentation: [YAML.Map.Element] {
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
    
    @NodeMapElementBuilder
    public var yamlRepresentation: [YAML.Map.Element] {
        "run".is(.text(script))
    }
}

extension Job.Runner {
    
    public func comment(_ comment: String) -> Job.Runner {
        mutating(self) {
            $0.comment = comment
        }
    }
    
    public static let macos11 = Job.Runner("macos-11")
        .comment("Check pre-installed software on https://github.com/actions/virtual-environments/blob/main/images/macos/macos-11-Readme.md")
    
}

@resultBuilder
public class JobStepsBuilder: ArrayBuilder<Job.Step> {
    
    public static func buildFinalResult(_ steps: [Job.Step]) -> [Job.Step] {
        steps
    }
}

@resultBuilder
public class NodeMapElementBuilder: ArrayBuilder<YAML.Map.Element> {
    
    public static func buildFinalResult(_ pairs: [YAML.Map.Element]) -> [YAML.Map.Element] {
        pairs
    }
}
