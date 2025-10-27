import Foundation
import Support
import YAMLBuilder

protocol JobStepMethod {
    
    @NodeMapElementBuilder
    var yamlRepresentation: [YAML.Map.Element] { get }
    
}

extension JobStepMethod where Self == GitHub.Workflow.Job.Step.ActionMethod {
    
    static func action(_ reference: String, inputs: [String: String] = [:]) -> Self {
        GitHub.Workflow.Job.Step.ActionMethod(reference: reference, inputs: inputs)
    }
    
}

extension JobStepMethod where Self == GitHub.Workflow.Job.Step.ScriptMethod {
    
    static func run(_ script: String) -> Self {
        GitHub.Workflow.Job.Step.ScriptMethod(script: script)
    }
    
}

extension GitHub.Workflow {
    public struct Job {
        
        public struct Runner: ExpressibleByStringLiteral, Sendable {
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
            public struct Use {
                var step: Step
            }

            public struct Run {
                var step: Step
            }
            
            struct ActionMethod {
                var reference: String
                var inputs: [String: String]
            }

            struct ScriptMethod {
                var script: String
            }
            
            var name: String
            var workingDirectory: String?
            var condition: String?
            var environment: [String: String] = [:]
            var method: JobStepMethod
            
            /// The action defined used as part of this step.
            ///
            /// This is not encoded as part of the step itself. Rather, it’s a reference used when building up the whole `Pipeline`.
            var actionDefinition: GitHub.Action?
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
        @JobStepsBuilder steps: () -> [Step],
    ) {
        self.init(
            id: id,
            name: name,
            runsOn: runsOn,
            needs: needs,
            steps: steps(),
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
public struct InputProvider<Inputs: ParameterSet> {
    var inputs = Inputs()
    
    fileprivate var inputValues: [String: String] = [:]
    
    public subscript(dynamicMember keyPath: KeyPath<Inputs, ActionInput>) -> String? {
        get {
            inputValues[inputs[keyPath: keyPath].id]
        }
        set {
            inputValues[inputs[keyPath: keyPath].id] = newValue
        }
    }
}

extension GitHub.Workflow.Job.Step.Use {
    
    public init<Action>(_ action: Action, name: String? = nil, with inputs: (inout InputProvider<Action.Inputs>) -> Void = { _ in }) where Action: GitHubAction {
        self.init(action: action, name: name, with: inputs)
    }
    
    public init<Action>(_ action: Action, name: String? = nil, with inputs: (inout InputProvider<Action.Inputs>) -> Void = { _ in }) where Action: GitHubCompositeAction {
        self.init(action: action, name: name, with: inputs)
        step.actionDefinition = .init(action)
    }
    
    private init<Action>(action: Action, name: String?, with inputs: (inout InputProvider<Action.Inputs>) -> Void) where Action: GitHubAction {
        var provider = InputProvider<Action.Inputs>()
        inputs(&provider)
        let missingInputs = Action.Inputs.allInputs.lazy
            .filter(\.isRequired)
            .filter { provider.inputValues[$0.id] == nil }
            .map(\.id)
            .sorted(by: <)
        Supervisor.precondition(missingInputs.isEmpty, "Missing value for required action input: \(missingInputs)")
        self.init(
            step: .init(name: name ?? action.name, method: .action(action.reference.value, inputs: provider.inputValues)),
        )
    }
    
    public func condition(_ condition: String?) -> GitHub.Workflow.Job.Step.Use {
        mutating(self) {
            $0.step.condition = condition
        }
    }
    
}

extension GitHub.Workflow.Job.Step.Run {
    
    public init(_ name: String, script: () -> String) {
        self.init(
            step: .init(name: name, method: .run(script())),
        )
    }
    
    public func workingDirectory(_ workingDirectory: String?) -> GitHub.Workflow.Job.Step.Run {
        mutating(self) {
            $0.step.workingDirectory = workingDirectory
        }
    }
    
    public func condition(_ condition: String?) -> GitHub.Workflow.Job.Step.Run {
        mutating(self) {
            $0.step.condition = condition
        }
    }
    
    public func environment(_ environment: [String: String]) -> GitHub.Workflow.Job.Step.Run {
        mutating(self) {
            $0.step.environment = environment
        }
    }
    
}

extension GitHub.Workflow.Job.Step {
    
    var content: YAML.Node {
        YAML.Node {
            "name".is(.text(name))
            
            if let condition {
                "if".is(.text(condition))
            }
            
            if let workingDirectory {
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

extension GitHub.Workflow.Job.Step.ActionMethod: JobStepMethod {
    
    @NodeMapElementBuilder
    var yamlRepresentation: [YAML.Map.Element] {
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

extension GitHub.Workflow.Job.Step.ScriptMethod: JobStepMethod {
    
    @NodeMapElementBuilder
    var yamlRepresentation: [YAML.Map.Element] {
        "run".is(.text(script))
    }
}

extension GitHub.Workflow.Job.Runner {
    
    public func comment(_ comment: String) -> GitHub.Workflow.Job.Runner {
        mutating(self) {
            $0.comment = comment
        }
    }
    
    public static let macos11 = GitHub.Workflow.Job.Runner("macos-11")
        .comment("Check pre-installed software on https://github.com/actions/virtual-environments/blob/main/images/macos/macos-11-Readme.md")
    
    public static let macos12 = GitHub.Workflow.Job.Runner("macos-12")
        .comment("Check pre-installed software on https://github.com/actions/virtual-environments/blob/main/images/macos/macos-12-Readme.md")
    
}

@resultBuilder
public class JobStepsBuilder: ArrayBuilder<GitHub.Workflow.Job.Step> {
    
    public static func buildExpression(_ use: GitHub.Workflow.Job.Step.Use) -> [GitHub.Workflow.Job.Step] {
        [use.step]
    }
    
    public static func buildExpression(_ run: GitHub.Workflow.Job.Step.Run) -> [GitHub.Workflow.Job.Step] {
        [run.step]
    }
    
    public static func buildFinalResult(_ steps: [GitHub.Workflow.Job.Step]) -> [GitHub.Workflow.Job.Step] {
        steps
    }
}

@resultBuilder
class NodeMapElementBuilder: ArrayBuilder<YAML.Map.Element> {
    
    static func buildFinalResult(_ pairs: [YAML.Map.Element]) -> [YAML.Map.Element] {
        pairs
    }
}
