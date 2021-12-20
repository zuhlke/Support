import TestingSupport
import XCTest
import YAMLBuilder

final class YAMLBuilderTests: XCTestCase {
    let encoder = YAMLEncoder()
    
    func testPrepareXcode() throws {
        let yaml = encoder.encode(prepareXcodeDocument)
        TS.assert(yaml, equals: prepareXcode)
    }
    
}

private let prepareXcodeDocument = YAML {
    "name".is("Prepare Xcode")
    "description".is("Select correct Xcode version and set up credentials")
    
    "runs".is {
        "using".is("composite")
        
        "steps".is {
            YAML.Node {
                "name".is("Select Xcode")
                "run".is("""
                sudo xcode-select --switch /Applications/Xcode_13.0.app
                xcodebuild -version
                swift --version
                """)
                "shell".is("bash")
                    .comment("Could also be zsh")
            }
        }
    }
}

private let prepareXcode = """
name: Prepare Xcode
description: Select correct Xcode version and set up credentials

runs:
  using: composite

  steps:
  - name: Select Xcode
    run: |
      sudo xcode-select --switch /Applications/Xcode_13.0.app
      xcodebuild -version
      swift --version

    # Could also be zsh
    shell: bash

"""
