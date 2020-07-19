#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Notification.Name {
    
    static var appWillTerminate: Notification.Name? {
        #if canImport(UIKit)
        return UIApplication.willTerminateNotification
        #elseif canImport(AppKit)
        return NSApplication.willTerminateNotification
        #else
        return nil
        #endif
    }
}
