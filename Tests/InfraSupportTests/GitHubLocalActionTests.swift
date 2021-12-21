import InfraSupport
import Support
import TestingSupport
import XCTest

class GitHubLocalActionTests: XCTestCase {}

private struct SelectXcodeVersionAction: GitHubLocalAction {
    var id = "select-xcode-version"
    var name = "Select Xcode Version"
    var description = "Set version of Xcode used for subsequent steps."
    
    struct Inputs: ParameterSet {
        
        @ActionInput("xcode-version", description: "The version of Xcode to use.")
        var xcodeVersion: String?
    }
    
    func run(with inputs: InputAccessor<Inputs>, outputs: Outputs) -> GitHub.Action.Run {
        Composite {
            Composite.Step("Select Xcode", shell: "bash") {
                """
                sudo xcode-select --switch /Applications/Xcode_\(inputs.$xcodeVersion).app
                xcodebuild -version
                swift --version
                """
            }
        }
    }
}
