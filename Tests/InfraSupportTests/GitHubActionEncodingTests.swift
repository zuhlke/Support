import TestingSupport
import XCTest
@testable import InfraSupport

final class GitHubActionEncodingTests: XCTestCase {
    let encoder = GitHub.MetadataEncoder()
    
    func testEncodingAction() throws {
        let action = GitHub.Action("Prepare Xcode") {
            "Select correct Xcode version and set up credentials."
        } runs: {
            Composite(steps: [
                .init(name: "Select Xcode", shell: "bash", run: """
                sudo xcode-select --switch /Applications/Xcode_13.0.app
                xcodebuild -version
                swift --version
                """),
            ])
        }
        let yaml = encoder.encode(action)
        TS.assert(yaml, equals: prepareXcode)
    }
    
}

private let prepareXcode = """
name: Prepare Xcode
description: Select correct Xcode version and set up credentials.

runs:
  using: composite

  steps:
  - name: Select Xcode
    run: |
      sudo xcode-select --switch /Applications/Xcode_13.0.app
      xcodebuild -version
      swift --version
    shell: bash

"""
