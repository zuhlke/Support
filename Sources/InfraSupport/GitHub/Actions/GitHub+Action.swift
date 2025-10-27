import Foundation
import YAMLBuilder

protocol GitHubActionRun {
    
    @NodeMappingBuilder
    var yamlDescription: YAML.Map { get }
}

extension GitHub {
    
    /// Represents a GitHub action.
    ///
    /// Action syntax is documented [here](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions).
    struct Action {
        typealias Run = GitHubActionRun
        
        var id: String
        var name: String
        var description: String
        var inputs: [Input]
        var outputs: [Output]
        var run: Run
    }
    
}

extension GitHub.Action {
    
    init(
        id: String,
        name: String,
        description: () -> String,
        @ActionInputsBuilder inputs: () -> [Input] = { [] },
        @ActionOutputsBuilder outputs: () -> [Output] = { [] },
        runs: () -> Run,
    ) {
        self.init(
            id: id,
            name: name,
            description: description(),
            inputs: inputs(),
            outputs: outputs(),
            run: runs(),
        )
    }
    
}

extension GitHub.Action {
    
    var projectFilePath: String {
        ".github/actions/\(id)/action.yml"
    }
    
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
class ActionInputsBuilder: ArrayBuilder<Input> {
    
    static func buildFinalResult(_ steps: [Input]) -> [Input] {
        steps
    }
}

@resultBuilder
class ActionOutputsBuilder: ArrayBuilder<Output> {
    
    static func buildFinalResult(_ steps: [Output]) -> [Output] {
        steps
    }
}
