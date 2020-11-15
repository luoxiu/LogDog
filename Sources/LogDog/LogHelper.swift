import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public enum LogHelper {}

// MARK: App

public extension LogHelper {
    static var appBuild: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    static var appName: String {
        let info = Bundle.main.infoDictionary
        if let appName = info?["CFBundleDisplayName"] as? String {
            return appName
        }
        if let appName = info?["CFBundleName"] as? String {
            return appName
        }
        return ProcessInfo.processInfo.processName
    }

    static var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

// MARK: Data

public extension LogHelper {
    static func stringify(_ data: Data, _ style: ByteCountFormatter.CountStyle = .file) -> String {
        enum Static {
            static var lazy = AtomicLazy<ByteCountFormatter>()
        }

        let formatter = Static.lazy.get(style, whenNotFound: { () -> ByteCountFormatter in
            let formatter = ByteCountFormatter()
            formatter.countStyle = style
            return formatter
        }())

        return formatter.string(fromByteCount: Int64(data.count))
    }
}

// MARK: Date

public extension LogHelper {
    static func stringify(_ date: Date, _ format: String) -> String {
        enum Static {
            static var lazy = AtomicLazy<DateFormatter>()
        }

        let formatter = Static.lazy.get(format, whenNotFound: {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            return formatter
        }())

        return formatter.string(from: date)
    }
}

// MARK: Device

public extension LogHelper {
    static var deviceName: String? {
        #if canImport(UIKit)
            return UIDevice.current.name
        #else
            return Host.current().localizedName
        #endif
    }

    /// https://github.com/apple/swift/blob/master/lib/Basic/LangOptions.cpp
    static var osName: String? {
        #if os(OSX)
            return "macOS"
        #elseif os(macOS)
            return "macOS"
        #elseif os(tvOS)
            return "tvOS"
        #elseif os(watchOS)
            return "watchOS"
        #elseif os(iOS)
            return "iOS"
        #elseif os(Linux)
            return "Linux"
        #elseif os(FreeBSD)
            return "FreeBSD"
        #elseif os(OpenBSD)
            return "OpenBSD"
        #elseif os(Windows)
            return "Windows"
        #elseif os(Android)
            return "Android"
        #elseif os(PS4)
            return "PS4"
        #elseif os(Cygwin)
            return "Cygwin"
        #elseif os(Haiku)
            return "Haiku"
        #elseif os(WASI)
            return "WASI"
        #else
            return nil
        #endif
    }
}

// MARK: Process

public extension LogHelper {
    static var currentProcessID: String {
        "\(ProcessInfo.processInfo.processIdentifier)"
    }
}

// MARK: String

public extension LogHelper {
    static func basename(of path: String, withExtensions: Bool = true) -> String {
        guard let index = path.lastIndex(of: "/") else {
            return path
        }

        let from = path.index(after: index)
        let filename = String(path[from...])

        if withExtensions {
            return filename
        }

        if let dot = filename.lastIndex(of: ".") {
            return String(filename[..<dot])
        }
        return filename
    }
}

// MARK: Thread

public extension LogHelper {
    static var currentDispatchQueueLabel: String {
        let label = __dispatch_queue_get_label(nil)
        return String(cString: label)
    }

    static var currentThreadID: String? {
        #if canImport(Darwin)
            var id: __uint64_t = 0
            if pthread_threadid_np(nil, &id) == 0 {
                return "\(id)"
            }
        #endif
        return nil
    }

    static var thread: String {
        if let name = Thread.current.name, name.count > 0 {
            return name
        }
        if Thread.isMainThread {
            return "main"
        }
        return currentDispatchQueueLabel
    }
}
