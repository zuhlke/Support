import Foundation

public struct SetGitCredentialsAction: GitHubLocalAction {
    public var id = "set-git-credentials"
    public var name = "Set git credentials"
    public var description = "Set git credentials with the provided actor and token."
    
    public struct Inputs: ParameterSet {
        
        public init() {}
        
        @ActionInput("github-actor", description: "GitHub actor used for fetching dependencies.")
        public var githubActor: String
        
        @ActionInput("github-access-token", description: "GitHub access token used for fetching dependencies.")
        public var githubAccessToken: String
    }
    
    public func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
        Composite {
            Composite.Step("Set Up Git Credentials", shell: "bash") {
                """
                echo "https://\(inputs.$githubActor):\(inputs.$githubAccessToken)@github.com" > ~/.git-credentials
                git config --global credential.helper store
                """
            }
        }
    }
    
}

extension GitHubLocalAction where Self == SetGitCredentialsAction {
    
    public static func setGitCredentials() -> Self {
        SetGitCredentialsAction()
    }
    
}
