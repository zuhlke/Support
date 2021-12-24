import Support
import TestingSupport
import XCTest
@testable import InfraSupport

class GitHubLocalActionTests: XCTestCase {
    
    func testConvertingATypedLocalAction() {
        let actual = GitHub.Action(SelectXcodeVersionAction())
        let expected = GitHub.Action(id: "select-xcode-version", name: "Select Xcode Version") {
            "Set version of Xcode used for subsequent steps."
        } inputs: {
            Input("xcode-version", isRequired: true) {
                "The version of Xcode to use."
            }.default("13.0")
        } outputs: {
            Output("swift-version") {
                "The version Swift used by this version of Xcode."
            }
        } runs: {
            Composite {
                Composite.Step("Select Xcode", shell: "bash") {
                    """
                    sudo xcode-select --switch /Applications/Xcode_${{ inputs.xcode-version }}.app
                    xcodebuild -version
                    swift --version
                    """
                }
            }
        }
        
        let encoder = GitHub.MetadataEncoder()
        let actualFile = encoder.projectFile(for: actual)
        let expectedFile = encoder.projectFile(for: expected)
        TS.assert(actualFile.pathInRepository, equals: expectedFile.pathInRepository)
        TS.assert(actualFile.contents, equals: expectedFile.contents)
    }
    
}

private struct SelectXcodeVersionAction: GitHubLocalAction {
    var id = "select-xcode-version"
    var name = "Select Xcode Version"
    var description = "Set version of Xcode used for subsequent steps."
    
    struct Inputs: ParameterSet {
        
        @ActionInput("xcode-version", description: "The version of Xcode to use.", default: "13.0")
        var xcodeVersion: String
    }
    
    struct Outputs: ParameterSet {
        
        @ActionOutput("swift-version", description: "The version Swift used by this version of Xcode.")
        var swiftVersion: String
    }
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
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
