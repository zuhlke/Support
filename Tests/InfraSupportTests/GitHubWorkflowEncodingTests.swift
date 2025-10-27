import TestingSupport
import XCTest
@testable import InfraSupport

final class GitHubWorkflowEncodingTests: XCTestCase {
    typealias Job = GitHub.Workflow.Job
    typealias Run = GitHub.Workflow.Job.Step.Run
    typealias Use = GitHub.Workflow.Job.Step.Use
    let encoder = GitHub.MetadataEncoder()
    
    func testEncodingWorkflow() throws {
        let workflow = GitHub.Workflow(id: "test", name: "Test My App") {
            .init(
                push: .init(tags: ["v1.*"]),
                pullRequest: .init(branches: ["main"]),
                schedule: .init(cron: "30 5,17 * * *"),
            )
        } jobs: {
            Job(
                id: "build-for-testing",
                name: "Build for Testing",
                runsOn: .macos11,
            ) {
                Use(.checkout())
                Use(PrepareXcode()) {
                    $0.$actor = "${{ github.actor }}"
                    $0.$accessToken = "${{ secrets.access_token }}"
                }
                Run("Build for Testing") {
                    "xcodebuild build-for-testing -workspace MyApp.xcworkspace -scheme MyAppInternal -destination \"name=iPhone 13 Pro\" -derivedDataPath DerivedData"
                }
                .condition("failure()")
                Run("Pack DerivedData") {
                    "zip -r DerivedData DerivedData"
                }
                Use(.uploadArtifact(), name: "Upload DerivedData") {
                    $0.$name = "DerivedData.zip"
                    $0.$path = "DerivedData.zip"
                    $0.$retentionDays = "1"
                }
            }
            Job(
                id: "test",
                name: "Test",
                runsOn: .macos11,
                needs: ["build-for-testing"],
            ) {
                Use(.checkout())
                Use(PrepareXcode()) {
                    $0.$actor = "${{ github.actor }}"
                    $0.$accessToken = "${{ secrets.access_token }}"
                }
                Use(.downloadArtifact(), name: "Download Derived Data") {
                    $0.$name = "DerivedData.zip"
                    $0.$path = "DerivedDataPack"
                }
                Run("Unpack Derived Data") {
                    """
                    unzip DerivedDataPack/DerivedData.zip
                    rm -rf DerivedDataPack
                    """
                }
                Run("Run Tests") {
                    "xcodebuild test-without-building -workspace MyApp.xcworkspace -scheme MyAppInternal -destination \"name=iPhone 13 Pro\" -derivedDataPath DerivedData"
                }
            }
            Job(
                id: "archive", name: "Archive",
                runsOn: .macos11,
                needs: ["build-for-testing"],
            ) {
                Use(.checkout())
                Use(PrepareXcode()) {
                    $0.$actor = "${{ github.actor }}"
                    $0.$accessToken = "${{ secrets.access_token }}"
                }
                Use(.downloadArtifact(), name: "Download Derived Data") {
                    $0.$name = "DerivedData.zip"
                    $0.$path = "DerivedDataPack"
                }
                Run("Unpack Derived Data") {
                    """
                    unzip DerivedDataPack/DerivedData.zip
                    rm -rf DerivedDataPack
                    """
                }
                Run("Set Up Developer Identity") {
                    "swift run ci setup-developer-identity --base64-encoded-identity $BASE64_ENCODED_IDENTITY --identity-password $IDENTITY_PASSWORD --base64-encoded-profile $BASE64_ENCODED_PROFILE"
                }
                .workingDirectory("CI")
                .environment([
                    "BASE64_ENCODED_PROFILE": "${{ secrets.base64_encoded_profile }}",
                    "BASE64_ENCODED_IDENTITY": "${{ secrets.base64_encoded_developer_identity }}",
                    "IDENTITY_PASSWORD": "${{ secrets.developer_identity_password }}",
                ])
                Run("Archive MyAppInternal") {
                    "xcodebuild archive -workspace MyApp.xcworkspace -scheme MyAppInternal -archivePath Archives/MyAppInternal -derivedDataPath DerivedData"
                }
                Run("Archive MyApp") {
                    "xcodebuild archive -workspace MyApp.xcworkspace -scheme MyApp -archivePath Archives/MyApp -derivedDataPath DerivedData"
                }
                Run("Pack Archives") {
                    "zip -r Archives Archives"
                }
                Use(.uploadArtifact(), name: "Upload Archives") {
                    $0.$name = "Archives.zip"
                    $0.$path = "Archives.zip"
                    $0.$retentionDays = "7"
                }
            }
        }
        let projectFile = encoder.projectFile(for: workflow)
        TS.assert(projectFile.pathInRepository, equals: ".github/workflows/test.yml")
        TS.assert(projectFile.contents, equals: testWorkflowContents)
    }
    
}

private struct PrepareXcode: GitHubAction {
    var name = "Prepare Xcode"
    
    var reference: Reference = "./.github/actions/prepare-xcode"
    
    struct Inputs: ParameterSet {
        
        @ActionInput("github-actor", description: "", optionality: .required)
        var actor: String
        
        @ActionInput("github-access-token", description: "", optionality: .required)
        var accessToken: String
        
    }
}

private let testWorkflowContents = """
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
      if: failure()
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
