import Logging

extension Logger {
    
    public init<Processor, OutputStream>(
        label: String,
        level: Logger.Level = .trace,
        metadata: Logger.Metadata = [:],
        processor: Processor,
        outputStream: OutputStream
    )
    where Processor: LogProcessor, OutputStream: LogOutputStream, Processor.Input == Void, Processor.Output == OutputStream.Output
    {
        var logger = Logger(label: label) { label -> LogHandler in
            LogDogLogHandler(label: label, processor: processor, outputStream: outputStream)
        }
        
        logger.logLevel = level
        
        self = logger
    }
}

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
