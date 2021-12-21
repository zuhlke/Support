import Foundation
import YAMLBuilder

extension GitHub {
    
    /// Represents a GitHub workflow.
    ///
    /// Workflow syntax is documented [here](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions).
    public struct Workflow {
        
        public struct Triggers {
            public struct CodeChangeOptions {
                var branches: [String]?
                var tags: [String]?
                var paths: [String]?
                
                public init(branches: [String]? = nil, tags: [String]? = nil, paths: [String]? = nil) {
                    self.branches = branches
                    self.tags = tags
                    self.paths = paths
                }
            }
            
            public struct Schedule {
                var cron: String
                
                public init(cron: String) {
                    self.cron = cron
                }
            }
            
            var push: CodeChangeOptions?
            var pullRequest: CodeChangeOptions?
            var schedule: Schedule?
            
            public init(push: GitHub.Workflow.Triggers.CodeChangeOptions? = nil, pullRequest: GitHub.Workflow.Triggers.CodeChangeOptions? = nil, schedule: GitHub.Workflow.Triggers.Schedule? = nil) {
                self.push = push
                self.pullRequest = pullRequest
                self.schedule = schedule
            }
        }
        
        var id: String
        var name: String
        var triggers: Triggers
        var jobs: [Job]
    }
    
}

extension GitHub.Workflow {
    
    public init(id: String, name: String, triggers: () -> Triggers, @WorkflowJobsBuilder jobs: () -> [Job]) {
        self.init(id: id, name: name, triggers: triggers(), jobs: jobs())
    }
    
}

extension GitHub.Workflow {
    
    var projectFilePath: String {
        ".github/workflows/\(id).yml"
    }
    
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

@resultBuilder
public class WorkflowJobsBuilder: ArrayBuilder<Job> {
    
    public static func buildFinalResult(_ jobs: [Job]) -> [Job] {
        jobs
    }
}
