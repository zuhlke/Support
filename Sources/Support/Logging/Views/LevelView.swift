#if LoggingFeature
#if canImport(SwiftUI)

import SwiftUI
import OSLog

struct LevelView: View {
    var size: CGFloat = 24
    var cornerRadius: CGFloat = 8
    var level: OSLogEntryLog.Level

    init(_ level: OSLogEntryLog.Level) {
        self.level = level
    }
    
    func symbol(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: cornerRadius, style: .circular).fill(color))
    }
    
    var body: some View {
        switch level {
        case .info:
            symbol(systemName: "info", color: .blue)
        case .debug:
            symbol(systemName: "stethoscope", color: .gray)
        case .error:
            symbol(systemName: "exclamationmark.2", color: .yellow)
        case .fault:
            symbol(systemName: "exclamationmark.3", color: .red)
        default:
            symbol(systemName: "bell.fill", color: .gray)
        }
    }
}

#endif
#endif
