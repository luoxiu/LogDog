import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum LogHookHelper {
    
    public static var currentTimestamp: String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }
    
    public static var currentThreadID: String? {
        #if canImport(Darwin)
        var id: __uint64_t = 0
        if pthread_threadid_np(nil, &id) == 0 {
            return "\(id)"
        }
        #endif
        return nil
    }
 
    public static var currentDispatchQueueLabel: String {
        let label = __dispatch_queue_get_label(nil)
        return String(cString: label)
    }

    public static var appName: String {
        let info = Bundle.main.infoDictionary
        if let appName = info?["CFBundleDisplayName"] as? String {
            return appName
        }
        if let appName = info?["CFBundleName"] as? String {
            return appName
        }
        return ProcessInfo.processInfo.processName
    }
    
    public static var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public static var appBuild: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    public static var deviceName: String? {
        #if canImport(UIKit)
        return UIDevice.current.name
        #else
        return Host.current().localizedName
        #endif
    }
    
    /// https://github.com/apple/swift/blob/master/lib/Basic/LangOptions.cpp
    public static var osName: String? {
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
