import Foundation
import ProcessStartTime
#if canImport(UIKit)
import UIKit
#endif

public enum ContextUtil {
    
    public static var currentThreadId: String {
        #if canImport(Darwin)
        var id: __uint64_t = 0
        if pthread_threadid_np(nil, &id) == 0 {
            return "\(id)"
        }
        #endif
        return "\(Int(bitPattern: ObjectIdentifier(Thread.current)))"
    }
    
    public static var currentThreadName: String? {
        if Thread.isMainThread {
            return "main"
        }
        return Thread.current.name
    }

    public static var currentDispatchQueueLabel: String? {
        let label = __dispatch_queue_get_label(nil)
        return String(cString: label)
    }
    
    public static let clientId: String = {
        enum Lazy {
            static let clientIdTransactionLock = NSLock()
            static let clientIdKey = "com.v2ambition.LogDog.Log.Context.clientId"
        }
        
        Lazy.clientIdTransactionLock.lock()
        defer { Lazy.clientIdTransactionLock.unlock() }
        
        let db = UserDefaults.standard
        
        var clientId: String! = db.string(forKey: Lazy.clientIdKey)
        if clientId == nil {
            clientId = UUID().uuidString
            db.set(clientId, forKey: Lazy.clientIdKey)
        }
        
        return clientId
    }()

    public static let appName: String = {
        let info = Bundle.main.infoDictionary
        if let appName = info?["CFBundleDisplayName"] as? String {
            return appName
        }
        if let appName = info?["CFBundleName"] as? String {
            return appName
        }
        return ProcessInfo.processInfo.processName
    }()
    
    public static let appVersion: String? = {
        if let info = Bundle.main.infoDictionary, let version = info["CFBundleShortVersionString"] as? String {
            return version
        }
        return nil
    }()
    
    public static let appBuild: String? = {
        if let info = Bundle.main.infoDictionary, let version = info["CFBundleVersion"] as? String {
            return version
        }
        return nil
    }()
    
    public static let appStartTime = ProcessInfo.processInfo.startTime
    
    public static let deviceName: String? = {
        #if canImport(UIKit)
        return UIDevice.current.name
        #else
        if let deviceName = Host.current().localizedName {
            return deviceName
        }
        return nil
        #endif
    }()
    
    /// https://github.com/apple/swift/blob/c59abcd543f70ee1b58e9156eef11aaa3a5cb8ca/lib/Basic/LangOptions.cpp
    public static let osName: String? = {
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
        // warning?
//        #elseif os(OpenBSD)
//        return "OpenBSD"
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
    }()
    
    public static let osVersion: String = {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }()
}
