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
    
    func testSetGitCredentialsActionDefinition() throws {
        let action = GitHub.Action(.setGitCredentials())
        
        let expectedContent = """
        name: Set git credentials
        description: Set git credentials with the provided actor and token.
        
        inputs:
          github-actor:
            description: GitHub actor used for fetching dependencies.
            required: true
        
          github-access-token:
            description: GitHub access token used for fetching dependencies.
            required: true
        
        runs:
          using: composite
        
          steps:
          - name: Set Up Git Credentials
            run: |
              echo "https://${{ inputs.github-actor }}:${{ inputs.github-access-token }}@github.com" > ~/.git-credentials
              git config --global credential.helper store
            shell: bash
        
        """
        
        let projectFile = encoder.projectFile(for: action)
        TS.assert(projectFile.pathInRepository, equals: ".github/actions/set-git-credentials/action.yml")
        TS.assert(projectFile.contents, equals: expectedContent)
    }
    
}
