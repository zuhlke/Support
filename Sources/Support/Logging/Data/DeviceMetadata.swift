#if canImport(Darwin)

import Foundation

struct DeviceMetadata: Equatable, Sendable {
    var operatingSystemVersion: String
    var deviceModel: String

    init(operatingSystemVersion: String, deviceModel: String) {
        self.operatingSystemVersion = operatingSystemVersion
        self.deviceModel = deviceModel
    }
}

extension DeviceMetadata {
    static let main = DeviceMetadata(
        operatingSystemVersion: ProcessInfo.processInfo.operatingSystemVersionString,
        deviceModel: deviceModel(),
    )
    
    private static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

#endif
