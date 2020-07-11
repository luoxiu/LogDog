import Foundation
import ProcessStartTime
#if canImport(UIKit)
import UIKit
#endif


extension LogEntry {
    
    public final class __Context {
        public let clientId: String
        
        public let appName: String
        
        public let appVersion: String?
        public let appBuild: String?
        public let appStartTime: Date
        
        public let deviceName: String?
        
        public let osName: String?
        public let osVersion: String
        
        public init(clientId: String,
                    appName: String, appVersion: String?, appBuild: String?, appStartTime: Date,
                    deviceName: String?,
                    osName: String?, osVersion: String) {
            self.clientId = clientId
            self.appName = appName
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.appStartTime = appStartTime
            self.deviceName = deviceName
            self.osName = osName
            self.osVersion = osVersion
        }
        
        public static let current = __Context(
            clientId: ContextUtil.clientId,
            appName: ContextUtil.appName,
            appVersion: ContextUtil.appVersion,
            appBuild: ContextUtil.appBuild,
            appStartTime: ContextUtil.appStartTime,
            deviceName: ContextUtil.deviceName,
            osName: ContextUtil.osName,
            osVersion: ContextUtil.osVersion
        )
    }
}
