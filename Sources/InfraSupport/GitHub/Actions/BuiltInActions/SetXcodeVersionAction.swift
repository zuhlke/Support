import Foundation

public struct SetXcodeVersionAction: GitHubLocalAction {
    public var id = "set-xcode-version"
    public var name = "Set Xcode Version"
    public var description = "Set correct Xcode version for command line use."
    
    var xcodeVersion: String
    
    public func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
        Composite {
            Composite.Step("Set Xcode Version", shell: "bash") {
                """
                sudo xcode-select --switch /Applications/Xcode_\(xcodeVersion).app
                xcodebuild -version
                swift --version
                """
            }
        }
    }
}

extension GitHubLocalAction where Self == SetXcodeVersionAction {
    
    public static func setXcodeVersion(to xcodeVersion: String) -> Self {
        SetXcodeVersionAction(xcodeVersion: xcodeVersion)
    }
    
}
