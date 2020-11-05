import Foundation

public enum LogHooks { }

// MARK: appBuild
extension LogHooks {
    public enum AppBuild: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let appBuild: LogHook = AnyLogHook {
        $0.parameters[AppBuild.self] = LogHelper.appBuild
    }
}

// MARK: appName
extension LogHooks {
    public enum AppName: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let appName: LogHook = AnyLogHook {
        $0.parameters[AppName.self] = LogHelper.appName
    }
}

// MARK: appVersion
extension LogHooks {
    public enum AppVersion: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let appVersion: LogHook = AnyLogHook {
        $0.parameters[AppVersion.self] = LogHelper.appVersion
    }
}

// MARK: currentDispatchQueueLabel
extension LogHooks {
    public struct CurrentDispatchQueueLabel: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let currentDispatchQueueLabel: LogHook = AnyLogHook {
        $0.parameters[CurrentDispatchQueueLabel.self] = LogHelper.currentDispatchQueueLabel
    }
}

// MARK: currentThreadID
extension LogHooks {
    public enum CurrentThreadID: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let currentThreadID: LogHook = AnyLogHook {
        $0.parameters[CurrentThreadID.self] = LogHelper.currentThreadID
    }
}

// MARK: currentThreadName
extension LogHooks {
    public enum CurrentThreadName: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let currentThreadName: LogHook = AnyLogHook {
        $0.parameters[CurrentThreadName.self] = Thread.current.name
    }
}

// MARK: currentTime
extension LogHooks {
    public enum CurrentTime: LogParameterCodingKey {
        public typealias Value = Date
    }
    
    public static let currentTime: LogHook = AnyLogHook {
        $0.parameters[CurrentTime.self] = Date()
    }
}

// MARK: currentTimestamp
extension LogHooks {
    public enum CurrentTimestamp: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let currentTimestamp: LogHook = AnyLogHook {
        $0.parameters[CurrentTimestamp.self] = LogHelper.currentTimestamp
    }
}

// MARK: isMainThread
extension LogHooks {
    public enum IsMainThread: LogParameterCodingKey {
        public typealias Value = Bool
    }
    
    public static let isMainThread: LogHook = AnyLogHook {
        $0.parameters[IsMainThread.self] = Thread.isMainThread
    }
}

// MARK: deviceName
extension LogHooks {
    public enum DeviceName: LogParameterCodingKey {
        public typealias Value = String
    }
    
    public static let deviceName: LogHook = AnyLogHook {
        $0.parameters[DeviceName.self] = LogHelper.deviceName
    }
}

// MARK: osName
extension LogHooks {
    public enum OSName: LogParameterCodingKey {
        public typealias Value = String
        
        public static var stringKey: String? {
            return "osName"
        }
    }
    
    public static let osName: LogHook = AnyLogHook {
        $0.parameters[OSName.self] = LogHelper.osName
    }
}
