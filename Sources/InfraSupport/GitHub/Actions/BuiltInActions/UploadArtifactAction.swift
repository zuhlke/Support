import Foundation

extension GitHubAction where Self == UploadArtifactAction {
    
    public static func uploadArtifact() -> Self {
        UploadArtifactAction()
    }
    
}

public struct UploadArtifactAction: GitHubAction {
    public var reference: Reference = "actions/upload-artifact@v2"
    public var name = "Upload Artifact"
    
    public struct Inputs: ParameterSet {
        
        public init() {}
        
        @ActionInput(
            "name",
            description: "Artifact name",
            optionality: .optional(defaultValue: "artifact")
        )
        public var name: String
        
        @ActionInput(
            "path",
            description: "A file, directory or wildcard pattern that describes what to upload",
            optionality: .required
        )
        public var path: String
        
        @ActionInput(
            "if-no-files-found",
            description: """
            The desired behavior if no files are found using the provided path.
            Available Options:
              `warn`: Output a warning but do not fail the action
              `error`: Fail the action with an error message
              `ignore`: Do not output any warnings or errors, the action does not fail
            """,
            optionality: .optional(defaultValue: "warn")
        )
        public var noFilesFoundBehavior: String
        
        @ActionInput(
            "retention-days",
            description: """
            Duration after which artifact will expire in days. 0 means using default retention.
            Minimum 1 day.
            Maximum 90 days unless changed from the repository settings page.
            """,
            optionality: .optional(defaultValue: "0")
        )
        public var retentionDays: String
        
    }
    
}
