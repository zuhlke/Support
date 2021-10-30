import TestingSupport
import XCTest
@testable import CISupport

final class GitHubActionEncodingTests: XCTestCase {
    let encoder = GitHub.MetadataEncoder()
    
    func testPrepareXcode() throws {
        let action = GitHub.Action(
            name: "Prepare Xcode",
            description: "Select correct Xcode version and set up credentials.",
            method: .composite(steps: [
                .init(name: "Select Xcode", shell: "bash", run: """
                sudo xcode-select --switch /Applications/Xcode_13.0.app
                xcodebuild -version
                swift --version
                """),
            ])
        )
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
