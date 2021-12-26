import Foundation

public struct SetGitCredentialsAction: GitHubCompositeAction {
    public var id = "set-git-credentials"
    public var name = "Set git credentials"
    public var description = "Set git credentials with the provided actor and token."
    
    public struct Inputs: ParameterSet {
        
        public init() {}
        
        @ActionInput("github-actor", description: "GitHub actor used for fetching dependencies.", optionality: .required)
        public var githubActor: String
        
        @ActionInput("github-access-token", description: "GitHub access token used for fetching dependencies.", optionality: .required)
        public var githubAccessToken: String
    }
    
    public func compositeActionSteps(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<EmptyGitHubLocalActionParameterSet>) -> [Step] {
        Step("Set Up Git Credentials", shell: "bash") {
            """
            echo "https://\(inputs.$githubActor):\(inputs.$githubAccessToken)@github.com" > ~/.git-credentials
            git config --global credential.helper store
            """
        }
    }
    
}

extension GitHubCompositeAction where Self == SetGitCredentialsAction {
    
    public static func setGitCredentials() -> Self {
        SetGitCredentialsAction()
    }
    
}
