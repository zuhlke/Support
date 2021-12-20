import InfraSupport
import TestingSupport
import XCTest

final class GitHubWorkflowEncodingTests: XCTestCase {
    let encoder = GitHub.MetadataEncoder()
    
    func testEncodingWorkflow() throws {
        let macos11 = Job.Runner("macos-11")
            .comment("Check pre-installed software on https://github.com/actions/virtual-environments/blob/main/images/macos/macos-11-Readme.md")
        let action = GitHub.Workflow("Test My App") {
            .init(
                push: .init(tags: ["v1.*"]),
                pullRequest: .init(branches: ["main"]),
                schedule: .init(cron: "30 5,17 * * *")
            )
        } jobs: {
            Job(
                id: "build-for-testing",
                name: "Build for Testing",
                runsOn: macos11
            ) {
                Job.Step("Checkout") {
                    .action("actions/checkout@v2")
                }
                Job.Step("Prepare Xcode") {
                    .action("./.github/actions/prepare-xcode", inputs: [
                        "github-actor": "${{ github.actor }}",
                        "github-access-token": "${{ secrets.access_token }}",
                    ])
                }
                Job.Step("Build for Testing") {
                    .run("xcodebuild build-for-testing -workspace MyApp.xcworkspace -scheme MyAppInternal -destination \"name=iPhone 13 Pro\" -derivedDataPath DerivedData")
                }
                Job.Step("Pack DerivedData") {
                    .run("zip -r DerivedData DerivedData")
                }
                Job.Step("Upload DerivedData") {
                    .action("actions/upload-artifact@v2", inputs: [
                        "name": "DerivedData.zip",
                        "path": "DerivedData.zip",
                        "retention-days": "1",
                    ])
                }
            }
            Job(
                id: "test",
                name: "Test",
                runsOn: macos11,
                needs: ["build-for-testing"]
            ) {
                Job.Step("Checkout") {
                    .action("actions/checkout@v2")
                }
                Job.Step("Prepare Xcode") {
                    .action("./.github/actions/prepare-xcode", inputs: [
                        "github-actor": "${{ github.actor }}",
                        "github-access-token": "${{ secrets.access_token }}",
                    ])
                }
                Job.Step("Download Derived Data") {
                    .action("actions/download-artifact@v2", inputs: [
                        "name": "DerivedData.zip",
                        "path": "DerivedDataPack",
                    ])
                }
                Job.Step("Unpack Derived Data") {
                    .run("""
                    unzip DerivedDataPack/DerivedData.zip
                    rm -rf DerivedDataPack
                    """)
                }
                Job.Step("Run Tests") {
                    .run("xcodebuild test-without-building -workspace MyApp.xcworkspace -scheme MyAppInternal -destination \"name=iPhone 13 Pro\" -derivedDataPath DerivedData")
                }
            }
            Job(
                id: "archive", name: "Archive",
                runsOn: macos11,
                needs: ["build-for-testing"]
            ) {
                Job.Step("Checkout") {
                    .action("actions/checkout@v2")
                }
                Job.Step("Prepare Xcode") {
                    .action("./.github/actions/prepare-xcode", inputs: [
                        "github-actor": "${{ github.actor }}",
                        "github-access-token": "${{ secrets.access_token }}",
                    ])
                }
                Job.Step("Download Derived Data") {
                    .action("actions/download-artifact@v2", inputs: [
                        "name": "DerivedData.zip",
                        "path": "DerivedDataPack",
                    ])
                }
                Job.Step("Unpack Derived Data") {
                    .run("""
                    unzip DerivedDataPack/DerivedData.zip
                    rm -rf DerivedDataPack
                    """)
                }
                Job.Step("Set Up Developer Identity") {
                    .run("swift run ci setup-developer-identity --base64-encoded-identity $BASE64_ENCODED_IDENTITY --identity-password $IDENTITY_PASSWORD --base64-encoded-profile $BASE64_ENCODED_PROFILE")
                }
                .workingDirectory("CI")
                .environment([
                    "BASE64_ENCODED_PROFILE": "${{ secrets.base64_encoded_profile }}",
                    "BASE64_ENCODED_IDENTITY": "${{ secrets.base64_encoded_developer_identity }}",
                    "IDENTITY_PASSWORD": "${{ secrets.developer_identity_password }}",
                ])
                Job.Step("Archive MyAppInternal") {
                    .run("xcodebuild archive -workspace MyApp.xcworkspace -scheme MyAppInternal -archivePath Archives/MyAppInternal -derivedDataPath DerivedData")
                }
                Job.Step("Archive MyApp") {
                    .run("xcodebuild archive -workspace MyApp.xcworkspace -scheme MyApp -archivePath Archives/MyApp -derivedDataPath DerivedData")
                }
                Job.Step("Pack Archives") {
                    .run("zip -r Archives Archives")
                }
                Job.Step("Upload Archives") {
                    .action("actions/upload-artifact@v2", inputs: [
                        "name": "Archives.zip",
                        "path": "Archives.zip",
                        "retention-days": "7",
                    ])
                }
            }
        }
        let yaml = encoder.encode(action)
        TS.assert(yaml, equals: prepareXcode)
    }
    
}

private let prepareXcode = """
name: Test My App

on:
  push:
    tags:
    - v1.*

  pull_request:
    branches:
    - main

  schedule:
    cron: 30 5,17 * * *

jobs:
  build-for-testing:
    name: Build for Testing

    # Check pre-installed software on https://github.com/actions/virtual-environments/blob/main/images/macos/macos-11-Readme.md
    runs-on: macos-11

    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Prepare Xcode
      uses: ./.github/actions/prepare-xcode
      with:
        github-access-token: ${{ secrets.access_token }}
        github-actor: ${{ github.actor }}

    - name: Build for Testing
      run: xcodebuild build-for-testing -workspace MyApp.xcworkspace -scheme MyAppInternal -destination "name=iPhone 13 Pro" -derivedDataPath DerivedData

    - name: Pack DerivedData
      run: zip -r DerivedData DerivedData

    - name: Upload DerivedData
      uses: actions/upload-artifact@v2
      with:
        name: DerivedData.zip
        path: DerivedData.zip
        retention-days: 1

  test:
    name: Test

    needs:
    - build-for-testing

    # Check pre-installed software on https://github.com/actions/virtual-environments/blob/main/images/macos/macos-11-Readme.md
    runs-on: macos-11

    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Prepare Xcode
      uses: ./.github/actions/prepare-xcode
      with:
        github-access-token: ${{ secrets.access_token }}
        github-actor: ${{ github.actor }}

    - name: Download Derived Data
      uses: actions/download-artifact@v2
      with:
        name: DerivedData.zip
        path: DerivedDataPack

    - name: Unpack Derived Data
      run: |
        unzip DerivedDataPack/DerivedData.zip
        rm -rf DerivedDataPack

    - name: Run Tests
      run: xcodebuild test-without-building -workspace MyApp.xcworkspace -scheme MyAppInternal -destination "name=iPhone 13 Pro" -derivedDataPath DerivedData

  archive:
    name: Archive

    needs:
    - build-for-testing

    # Check pre-installed software on https://github.com/actions/virtual-environments/blob/main/images/macos/macos-11-Readme.md
    runs-on: macos-11

    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Prepare Xcode
      uses: ./.github/actions/prepare-xcode
      with:
        github-access-token: ${{ secrets.access_token }}
        github-actor: ${{ github.actor }}

    - name: Download Derived Data
      uses: actions/download-artifact@v2
      with:
        name: DerivedData.zip
        path: DerivedDataPack

    - name: Unpack Derived Data
      run: |
        unzip DerivedDataPack/DerivedData.zip
        rm -rf DerivedDataPack

    - name: Set Up Developer Identity
      working-directory: CI
      env:
        BASE64_ENCODED_IDENTITY: ${{ secrets.base64_encoded_developer_identity }}
        BASE64_ENCODED_PROFILE: ${{ secrets.base64_encoded_profile }}
        IDENTITY_PASSWORD: ${{ secrets.developer_identity_password }}
      run: swift run ci setup-developer-identity --base64-encoded-identity $BASE64_ENCODED_IDENTITY --identity-password $IDENTITY_PASSWORD --base64-encoded-profile $BASE64_ENCODED_PROFILE

    - name: Archive MyAppInternal
      run: xcodebuild archive -workspace MyApp.xcworkspace -scheme MyAppInternal -archivePath Archives/MyAppInternal -derivedDataPath DerivedData

    - name: Archive MyApp
      run: xcodebuild archive -workspace MyApp.xcworkspace -scheme MyApp -archivePath Archives/MyApp -derivedDataPath DerivedData

    - name: Pack Archives
      run: zip -r Archives Archives

    - name: Upload Archives
      uses: actions/upload-artifact@v2
      with:
        name: Archives.zip
        path: Archives.zip
        retention-days: 7

"""
