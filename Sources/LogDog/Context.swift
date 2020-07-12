import Foundation
import ProcessStartTime
#if canImport(UIKit)
import UIKit
#endif

public typealias Context = Logger.Metadata

public struct ContextCapture<T: LossLessMetadataValueConvertible> {
    
    public let name: String
    
    public let capture: () -> T?
    
    public init(_ name: String, _ capture: @escaping () -> T?) {
        self.name = name
        self.capture = capture
    }
}

extension LogProcessor {
    
    public func register<T: LossLessMetadataValueConvertible>(_ capture: ContextCapture<T>) {
        dynamicContext[capture.name] = { () -> T in
            capture.capture()!
        }
    }
}

extension LogEntry {
    
    public func get<T>(_ descriptor: ContextCapture<T>) -> T? {
        guard let value = context[descriptor.name] else {
            return nil
        }
        return T(value)
    }
}

extension ContextCapture {
    
    public static var currentThreadId: ContextCapture<String> {
        .init(#function) {
            #if canImport(Darwin)
            var id: __uint64_t = 0
            if pthread_threadid_np(nil, &id) == 0 {
                return "\(id)"
            }
            #endif
            return nil
        }
    }
    
    public static var currentThreadName: ContextCapture<String> {
        .init(#function) {
            Thread.current.name
        }
    }
    
    public static var isMainThread: ContextCapture<Bool> {
        .init(#function) {
            Thread.isMainThread
        }
    }
 
    public static var currentDispatchQueueLabel: ContextCapture<String> {
        .init(#function) {
            let label = __dispatch_queue_get_label(nil)
            return String(cString: label)
        }
    }

    public static var appName: ContextCapture<String> {
        .init(#function) {
            let info = Bundle.main.infoDictionary
            if let appName = info?["CFBundleDisplayName"] as? String {
                return appName
            }
            if let appName = info?["CFBundleName"] as? String {
                return appName
            }
            return ProcessInfo.processInfo.processName
        }
    }
    
    public static var appVersion: ContextCapture<String> {
        .init(#function) {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }
    }
    
    public static var appBuild: ContextCapture<String> {
        .init(#function) {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        }
    }
    
    public static var appStartTime: ContextCapture<Date> {
        .init(#function) {
            ProcessInfo.processInfo.startTime
        }
    }
    
    public static var deviceName: ContextCapture<String> {
        .init(#function) {
            #if canImport(UIKit)
            return UIDevice.current.name
            #else
            return Host.current().localizedName
            #endif
        }
    }
    
    /// https://github.com/apple/swift/blob/master/lib/Basic/LangOptions.cpp
    public static var osName: ContextCapture<String> {
        .init(#function) {
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
            #elseif swift(>=5.3) && os(OpenBSD)
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

    public static var osVersion: ContextCapture<OperatingSystemVersion> {
        .init(#function) {
            ProcessInfo.processInfo.operatingSystemVersion
        }
    }
    
    public static var backtrace: ContextCapture<[StackFrame]> {
        .init(#function) {
            Backtrace.backtrace()
        }
    }
}
