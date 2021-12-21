import Foundation
import YAMLBuilder

public protocol GitHubActionRun {
    
    @NodeMappingBuilder
    var yamlDescription: YAML.Map { get }
}

extension GitHub {
    
    /// Represents a GitHub action.
    ///
    /// Action syntax is documented [here](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions).
    public struct Action {
        public typealias Run = GitHubActionRun
        
        var id: String
        var name: String
        var description: String
        var inputs: [Input]
        var outputs: [Output]
        var run: Run
    }
    
}

extension GitHub.Action {
    
    public init(
        id: String,
        name: String,
        description: () -> String,
        @ActionInputsBuilder inputs: () -> [Input] = { [] },
        @ActionOutputsBuilder outputs: () -> [Output] = { [] },
        runs: () -> Run
    ) {
        self.init(
            id: id,
            name: name,
            description: description(),
            inputs: inputs(),
            outputs: outputs(),
            run: runs()
        )
    }
    
}

extension GitHub.Action {
    
    var yamlRepresentation: YAML {
        YAML {
            "name".is(.text(name))
            "description".is(.text(description))
            
            if !inputs.isEmpty {
                "inputs".is {
                    for input in inputs {
                        input.yamlDescription
                    }
                }
            }
            
            if !outputs.isEmpty {
                "outputs".is {
                    for output in outputs {
                        output.yamlDescription
                    }
                }
            }
            
            "runs".is(.map(run.yamlDescription))
        }
    }
    
}

@resultBuilder
public class ActionInputsBuilder: ArrayBuilder<Input> {
    
    public static func buildFinalResult(_ steps: [Input]) -> [Input] {
        steps
    }
}

@resultBuilder
public class ActionOutputsBuilder: ArrayBuilder<Output> {
    
    public static func buildFinalResult(_ steps: [Output]) -> [Output] {
        steps
    }
}
