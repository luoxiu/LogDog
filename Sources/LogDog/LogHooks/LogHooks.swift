import Foundation

public enum LogHooks { }

extension LogHooks {
    // MARK: currentTime
    public struct CurrentTimeKey: LogParameterKey {
        public typealias Value = Date
    }
    
    public static let currentTime: LogHook = {
        $0.parameters[CurrentTimeKey.self] = Date()
    }
    
    // MARK: currentThreadID
    public struct CurrentThreadIDKey: LogParameterKey {
        public typealias Value = String
    }
    
    public static let currentThreadID: LogHook = {
        $0.parameters[CurrentThreadIDKey.self] = LogHookHelper.currentThreadID
    }
    
    // MARK: currentThreadName
    public struct CurrentThreadNameKey: LogParameterKey {
        public typealias Value = String
    }

    public static let currentThreadName: LogHook = {
        $0.parameters[CurrentThreadNameKey.self] = Thread.current.name
    }
    
    // MARK: isMainThread
    public struct IsMainThreadKey: LogParameterKey {
        public typealias Value = Bool
    }

    public static let isMainThread: LogHook = {
        $0.parameters[IsMainThreadKey.self] = Thread.isMainThread
    }

    // MARK: currentDispatchQueueLabel
    public struct CurrentDispatchQueueLabel: LogParameterKey {
        public typealias Value = String
    }
    
    public static let currentDispatchQueueLabel: LogHook = {
        $0.parameters[CurrentDispatchQueueLabel.self] = LogHookHelper.currentDispatchQueueLabel
    }

    // MARK: appName
    public struct AppNameKey: LogParameterKey {
        public typealias Value = String
    }
    
    public static let appName: LogHook = {
        $0.parameters[AppNameKey.self] = LogHookHelper.appName
    }
    
    // MARK: appVersion
    public struct AppVersionKey: LogParameterKey {
        public typealias Value = String
    }

    public static let appVersion: LogHook = {
        $0.parameters[AppVersionKey.self] = LogHookHelper.appVersion
    }

    // MARK: appBuild
    public struct AppBuildKey: LogParameterKey {
        public typealias Value = String
    }
    
    public static let appBuild: LogHook = {
        $0.parameters[AppBuildKey.self] = LogHookHelper.appBuild
    }

    // MARK: deviceName
    public struct DeviceNameKey: LogParameterKey {
        public typealias Value = String
    }
    
    public static let deviceName: LogHook = {
        $0.parameters[DeviceNameKey.self] = LogHookHelper.deviceName
    }
    
    // MARK: osName
    public struct OSNameKey: LogParameterKey {
        public typealias Value = String
    }
    
    public static let osName: LogHook = {
        $0.parameters[OSNameKey.self] = LogHookHelper.osName
    }
}
