import TestingSupport
import XCTest
@testable import Support

class UserDefaultsTests: XCTestCase {
    
    // MARK: - Normal defaults
    
    func testPropertiesWithoutDefault() {
        withTemporaryDefaultKey { defaults, key in
            let property = defaults.property(ofType: String.self, forKey: key)
            XCTAssertNil(property.wrappedValue)
            
            var objectChangesCount = 0
            let cancelable = property.objectWillChange.sink {
                objectChangesCount += 1
            }
            defer { cancelable.cancel() }
            
            let expected = UUID().uuidString
            defaults.setValue(expected, forKey: key)
            TS.assert(objectChangesCount, equals: 1)
            TS.assert(property.wrappedValue, equals: expected)
            
            let expected2 = UUID().uuidString
            property.wrappedValue = expected2
            TS.assert(objectChangesCount, equals: 2)
            TS.assert(defaults.string(forKey: key), equals: expected2)
            
            defaults.setValue(5, forKey: key)
            XCTAssertNil(property.wrappedValue)
            
            defaults.removeObject(forKey: key)
            XCTAssertNil(property.wrappedValue)
            
            property.wrappedValue = nil
            XCTAssertNil(property.wrappedValue)
        }
    }
    
    func testPropertiesWithDefault() {
        withTemporaryDefaultKey { defaults, key in
            let defaultValue = UUID().uuidString
            let property = defaults.property(ofType: String.self, forKey: key, defaultingTo: defaultValue)
            TS.assert(property.wrappedValue, equals: defaultValue)
            
            var objectChangesCount = 0
            let cancelable = property.objectWillChange.sink {
                objectChangesCount += 1
            }
            defer { cancelable.cancel() }
            
            let expected = UUID().uuidString
            defaults.setValue(expected, forKey: key)
            TS.assert(objectChangesCount, equals: 1)
            TS.assert(property.wrappedValue, equals: expected)
            
            let expected2 = UUID().uuidString
            property.wrappedValue = expected2
            TS.assert(objectChangesCount, equals: 2)
            TS.assert(defaults.string(forKey: key), equals: expected2)
            
            defaults.setValue(5, forKey: key)
            TS.assert(property.wrappedValue, equals: defaultValue)
            
            defaults.removeObject(forKey: key)
            TS.assert(property.wrappedValue, equals: defaultValue)
        }
    }
    
    // MARK: - Settings
    
    func testCreatingNonExistingSettingFails() {
        let key = UUID().uuidString
        TS.assertFatalError {
            _ = UserDefaults.standard.setting(ofType: String.self, forKey: key)
        }
    }
    
    func testCreatingSettingWithWrongTypeFails() throws {
        let key = UUID().uuidString
        let defaultValue = UUID().uuidString
        let specifiers: [AnyHashable] = [
            [
                "Type": "PSTextFieldSpecifier",
                "Key": key,
                "DefaultValue": defaultValue,
            ],
        ]
        try withTemporarySettings(specifiers: specifiers) { defaults, bundle in
            TS.assertFatalError {
                _ = defaults.setting(ofType: Int.self, forKey: key, bundle: bundle)
            }
        }
    }
    
    func testCreatingSettingWithoutDefaultValueFails() throws {
        let key = UUID().uuidString
        let specifiers: [AnyHashable] = [
            [
                "Type": "PSTextFieldSpecifier",
                "Key": key,
            ],
        ]
        try withTemporarySettings(specifiers: specifiers) { defaults, bundle in
            TS.assertFatalError {
                _ = defaults.setting(ofType: String.self, forKey: key, bundle: bundle)
            }
        }
    }
    
    func testCreatingSettingWithStringType() throws {
        let key = UUID().uuidString
        let defaultValue = UUID().uuidString
        let specifiers: [AnyHashable] = [
            [
                "Key": key,
                "DefaultValue": defaultValue,
            ],
        ]
        try withTemporarySettings(specifiers: specifiers) { defaults, bundle in
            let property = UserDefaults.standard.setting(ofType: String.self, forKey: key, bundle: bundle)
            TS.assert(property.wrappedValue, equals: defaultValue)
        }
    }
    
    func testCreatingSettingFromNonRootPlistWithStringType() throws {
        let key = UUID().uuidString
        let defaultValue = UUID().uuidString
        let specifiers: [AnyHashable] = [
            [
                "Key": key,
                "DefaultValue": defaultValue,
            ],
        ]
        try withTemporarySettings(specifiers: specifiers, settingsFileName: "Other") { defaults, bundle in
            let property = UserDefaults.standard.setting(ofType: String.self, forKey: key, bundle: bundle)
            TS.assert(property.wrappedValue, equals: defaultValue)
        }
    }
    
    func testCreatingSettingWithIntType() throws {
        let key = UUID().uuidString
        let defaultValue = Int.random(in: 0 ... 1000)
        let specifiers: [[String: AnyHashable]] = [
            [
                "Key": key,
                "DefaultValue": defaultValue,
            ],
        ]
        try withTemporarySettings(specifiers: specifiers) { defaults, bundle in
            let property = UserDefaults.standard.setting(ofType: Int.self, forKey: key, bundle: bundle)
            TS.assert(property.wrappedValue, equals: defaultValue)
        }
    }
    
    func testCreatingSettingWithBoolType() throws {
        let key = UUID().uuidString
        let defaultValue = true
        let specifiers: [[String: AnyHashable]] = [
            [
                "Key": key,
                "DefaultValue": defaultValue,
            ],
        ]
        try withTemporarySettings(specifiers: specifiers) { defaults, bundle in
            let property = UserDefaults.standard.setting(ofType: Bool.self, forKey: key, bundle: bundle)
            TS.assert(property.wrappedValue, equals: defaultValue)
        }
    }
    
    func testCreatingSettingWithVaryingFloatTypesType() throws {
        let key = UUID().uuidString
        let defaultValue = 13.0
        let specifiers: [[String: AnyHashable]] = [
            [
                "Key": key,
                "DefaultValue": defaultValue,
            ],
        ]
        try withTemporarySettings(specifiers: specifiers) { defaults, bundle in
            let property = UserDefaults.standard.setting(ofType: Double.self, forKey: key, bundle: bundle)
            TS.assert(property.wrappedValue, equals: defaultValue)
            let property2 = UserDefaults.standard.setting(ofType: Float.self, forKey: key, bundle: bundle)
            TS.assert(property2.wrappedValue, equals: Float(defaultValue))
        }
    }
    
}

extension UserDefaultsTests {
    
    func withTemporaryDefaultKey(perform work: (UserDefaults, String) throws -> Void) rethrows {
        let defaults = UserDefaults.standard
        let key = UUID().uuidString
        
        defaults.removeObject(forKey: key)
        try work(defaults, key)
        defaults.removeObject(forKey: key)
    }
    
    func withTemporarySettings(specifiers: [AnyHashable], settingsFileName: String = "Root", perform work: (UserDefaults, Bundle) throws -> Void) throws {
        let fileManager = FileManager()
        try fileManager.makeTemporaryDirectory { directory in
            let bundle = Bundle(url: directory)!
            
            let settingsBundleDirectory = directory.appendingPathComponent("Settings.bundle")
            let rootFilePath = settingsBundleDirectory.appendingPathComponent("\(settingsFileName).plist")
            
            try fileManager.createDirectory(
                at: settingsBundleDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            let dict = [
                "PreferenceSpecifiers": specifiers,
            ]
            
            try PropertyListSerialization
                .data(fromPropertyList: dict, format: .binary, options: 0)
                .write(to: rootFilePath)
            
            try work(UserDefaults.standard, bundle)
        }
    }
    
}
