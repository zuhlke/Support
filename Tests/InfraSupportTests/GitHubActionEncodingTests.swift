import TestingSupport
import XCTest
import InfraSupport

final class GitHubActionEncodingTests: XCTestCase {
    let encoder = GitHub.MetadataEncoder()
    
    func testEncodingAction() throws {
        let action = GitHub.Action("Prepare Xcode") {
            "Select correct Xcode version and set up credentials."
        } runs: {
            Composite {
                Composite.Step(shell: "sh") {
                    "echo hi"
                }
                .id("echo-step")
                Composite.Step("Select Xcode", shell: "bash") {
                    """
                    sudo xcode-select --switch /Applications/Xcode_13.0.app
                    xcodebuild -version
                    swift --version
                    """
                }
            }
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
  - id: echo-step
    run: echo hi
    shell: sh

  - name: Select Xcode
    run: |
      sudo xcode-select --switch /Applications/Xcode_13.0.app
      xcodebuild -version
      swift --version
    shell: bash

"""
