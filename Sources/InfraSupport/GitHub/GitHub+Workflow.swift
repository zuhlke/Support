import Foundation
import YAMLBuilder

extension GitHub {
    
    /// Represents a GitHub workflow.
    ///
    /// Workflow syntax is documented [here](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions).
    public struct Workflow {
        
        struct Triggers {
            struct CodeChangeOptions {
                var branches: [String]?
                var tags: [String]?
                var paths: [String]?
            }
            
            struct Schedule {
                var cron: String
            }
            
            var push: CodeChangeOptions?
            var pullRequest: CodeChangeOptions?
            var schedule: Schedule?
        }
        
        struct Job {
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

        var name: String
        var triggers: Triggers
        var jobs: [Job]
    }
    
}

extension GitHub.Workflow {
    
    init(_ name: String, triggers: () -> Triggers, jobs: () -> [Job]) {
        self.init(name: name, triggers: triggers(), jobs: jobs())
    }
    
}

extension GitHub.Workflow {
    
    var yamlRepresentation: YAML {
        YAML {
            "name".is(.text(name))
            
            "on".is {
                if let push = triggers.push {
                    "push".is(push.content)
                }
                if let pullRequest = triggers.pullRequest {
                    "pull_request".is(pullRequest.content)
                }
                if let schedule = triggers.schedule {
                    "schedule".is(schedule.content)
                }
            }
            
            "jobs".is {
                for job in jobs {
                    job.id.is(job.content)
                }
            }
            
        }
    }
    
}

private extension GitHub.Workflow.Triggers.CodeChangeOptions {
    
    var content: YAML.Node {
        YAML.Node {
            if let branches = branches {
                "branches".is {
                    for branch in branches {
                        branch
                    }
                }
            }
            if let tags = tags {
                "tags".is {
                    for tag in tags {
                        tag
                    }
                }
            }
            if let paths = paths {
                "paths".is {
                    for path in paths {
                        path
                    }
                }
            }
        }
    }
    
}

private extension GitHub.Workflow.Triggers.Schedule {
    
    var content: YAML.Node {
        YAML.Node {
            "cron".is(.text(cron))
        }
    }
    
}

private extension GitHub.Workflow.Job {
    
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
