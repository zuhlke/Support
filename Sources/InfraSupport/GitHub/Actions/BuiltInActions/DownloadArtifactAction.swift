import Foundation

extension GitHubAction where Self == DownloadArtifactAction {
    
    public static func downloadArtifact() -> Self {
        DownloadArtifactAction()
    }
    
}

public struct DownloadArtifactAction: GitHubAction {
    public var reference: Reference = "actions/download-artifact@v2"
    public var name = "Download Artifact"
    
    public struct Inputs: ParameterSet {
        
        public init() {}
        
        @ActionInput(
            "name",
            description: "Artifact name",
            optionality: .optional(defaultValue: "")
        )
        public var name: String
        
        @ActionInput(
            "path",
            description: "Destination path",
            optionality: .optional(defaultValue: "")
        )
        public var path: String
        
    }
    
}
