import InfraSupport
import Support
import TestingSupport
import XCTest

final class GitHubActionEncodingTests: XCTestCase {
    let encoder = GitHub.MetadataEncoder()
    
    func testEncodingAction() throws {
        let action = GitHub.Action("Prepare Xcode") {
            "Select correct Xcode version and set up credentials."
        } inputs: {
            Input("tool-version", isRequired: true) {
                "Version of the tool to use."
            }.default("14")
        } outputs: {
            Output("greeting-response") {
                "The greeting from the tool."
            }.value("${{ some-output }}")
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
                .environment([
                    "user": "me",
                    "password": "secret",
                ])
            }
        }
        let yaml = encoder.encode(action)
        TS.assert(yaml, equals: prepareXcode)
    }
    
}

private let prepareXcode = """
name: Prepare Xcode
description: Select correct Xcode version and set up credentials.

inputs:
  tool-version:
    description: Version of the tool to use.
    required: true
    default: 14

outputs:
  greeting-response:
    description: The greeting from the tool.
    value: ${{ some-output }}

runs:
  using: composite

  steps:
  - id: echo-step
    run: echo hi
    shell: sh

  - name: Select Xcode
    env:
      password: secret
      user: me
    run: |
      sudo xcode-select --switch /Applications/Xcode_13.0.app
      xcodebuild -version
      swift --version
    shell: bash

"""
