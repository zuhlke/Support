import InfraSupport
import Support
import TestingSupport
import XCTest

final class GitHubActionPredefinedValuesTests: XCTestCase {
    let encoder = GitHub.MetadataEncoder()
    
    func testSetXcodeVersionActionDefinition() throws {
        let action = GitHub.Action(.setXcodeVersion(to: "13.2"))
        
        let expectedContent = """
        name: Set Xcode Version
        description: Set correct Xcode version for command line use.
        
        runs:
          using: composite
        
          steps:
          - name: Set Xcode Version
            run: |
              sudo xcode-select --switch /Applications/Xcode_13.2.app
              xcodebuild -version
              swift --version
            shell: bash
        
        """
        
        let projectFile = encoder.projectFile(for: action)
        TS.assert(projectFile.pathInRepository, equals: ".github/actions/set-xcode-version/action.yml")
        TS.assert(projectFile.contents, equals: expectedContent)
    }
    
}
