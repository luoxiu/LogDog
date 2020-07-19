import Logging

public extension Logger {
    
    func execute(level: Logger.Level, _ closure: () -> Void) {
        if logLevel <= level {
            closure()
        }
    }
    
    func traceExecute(_ closure: () -> Void) {
        execute(level: .trace, closure)
    }
    
    func debugExecute(_ closure: () -> Void) {
        execute(level: .debug, closure)
    }
    
    func infoExecute(_ closure: () -> Void) {
        execute(level: .info, closure)
    }
    
    func noticeExecute(_ closure: () -> Void) {
        execute(level: .notice, closure)
    }
    
    func warningExecute(_ closure: () -> Void) {
        execute(level: .warning, closure)
    }
    
    func errorExecute(_ closure: () -> Void) {
        execute(level: .error, closure)
    }
    
    func criticalExecute(_ closure: () -> Void) {
        execute(level: .critical, closure)
    }
}
