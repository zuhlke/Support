import Foundation

extension GitHubAction where Self == CheckoutAction {
    
    public static func checkout() -> Self {
        CheckoutAction()
    }
    
}

public struct CheckoutAction: GitHubAction {
    public var reference: Reference = "actions/checkout@v2"
    public var name = "Checkout"
    
    public struct Inputs: ParameterSet {
        
        public init() {}
        
        @ActionInput(
            "repository",
            description: "Repository name with owner. For example, actions/checkout",
            optionality: .optional(defaultValue: "${{ github.repository }}")
        )
        public var repository: String
        
        @ActionInput(
            "ref",
            description: "The branch, tag or SHA to checkout.",
            optionality: .optional(defaultValue: "")
        )
        public var reference: String
        
        @ActionInput(
            "token",
            description: "Personal access token (PAT) used to fetch the repository.",
            optionality: .optional(defaultValue: "")
        )
        public var token: String
        
        @ActionInput(
            "ssh-key",
            description: "SSH key used to fetch the repository.",
            optionality: .optional(defaultValue: "")
        )
        public var sshKey: String
        
        @ActionInput(
            "ssh-known-hosts",
            description: "Known hosts in addition to the user and global host key database.",
            optionality: .optional(defaultValue: "")
        )
        public var sshKnownHosts: String
        
        @ActionInput(
            "ssh-strict",
            description: "Whether to perform strict host key checking.",
            optionality: .optional(defaultValue: "true")
        )
        public var sshIsStrict: String
        
        @ActionInput(
            "persist-credentials",
            description: "Whether to configure the token or SSH key with the local git config",
            optionality: .optional(defaultValue: "true")
        )
        public var shouldPersistCredentials: String
        
        @ActionInput(
            "path",
            description: "Relative path under $GITHUB_WORKSPACE to place the repository",
            optionality: .optional(defaultValue: "")
        )
        public var path: String
        
        @ActionInput(
            "clean",
            description: "Whether to execute `git clean -ffdx && git reset --hard HEAD` before fetching",
            optionality: .optional(defaultValue: "true")
        )
        public var clean: String
        
        @ActionInput(
            "fetch-depth",
            description: "Number of commits to fetch. 0 indicates all history for all branches and tags.",
            optionality: .optional(defaultValue: "1")
        )
        public var fetchDepth: String
        
        @ActionInput(
            "lfs",
            description: "Whether to download Git-LFS files.",
            optionality: .optional(defaultValue: "false")
        )
        public var shouldDownloadLFS: String
        
        @ActionInput(
            "submodules",
            description: "Whether to checkout submodules: `true` to checkout submodules or `recursive` to recursively checkout submodules.",
            optionality: .optional(defaultValue: "")
        )
        public var submodules: String
        
    }
    
}
