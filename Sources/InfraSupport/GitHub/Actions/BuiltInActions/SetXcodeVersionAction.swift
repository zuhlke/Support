import Foundation

public struct SetXcodeVersionAction: GitHubCompositeAction {
    public var id = "set-xcode-version"
    public var name = "Set Xcode Version"
    public var description = "Set correct Xcode version for command line use."
    
    var xcodeVersion: String
    
    public func compositeActionSteps(inputs: InputAccessor<EmptyParameterSet>, outputs: OutputAccessor<EmptyParameterSet>) -> [Step] {
        Step("Set Xcode Version", shell: "bash") {
            """
            sudo xcode-select --switch /Applications/Xcode_\(xcodeVersion).app
            xcodebuild -version
            swift --version
            """
        }
    }
}

extension GitHubCompositeAction where Self == SetXcodeVersionAction {
    
    public static func setXcodeVersion(to xcodeVersion: String) -> Self {
        SetXcodeVersionAction(xcodeVersion: xcodeVersion)
    }
    
}
