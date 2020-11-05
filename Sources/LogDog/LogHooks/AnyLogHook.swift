public struct AnyLogHook: LogHook {
    
    private let hook: AbstractHook
    
    public init<Hook: LogHook>(_ hook: Hook) {
        self.hook = HookBox(hook)
    }
    
    public init(_ closure: @escaping (LogEntry) -> Void) {
        self.hook = ClosureBox(closure)
    }
    
    public func hook(_ entry: LogEntry) {
        self.hook.hook(entry)
    }
}

private class AbstractHook: LogHook {
    
    func hook(_ entry: LogEntry) {
        fatalError()
    }
}

private final class ClosureBox: AbstractHook {
    
    private let closure: (LogEntry) -> Void
    
    init(_ closure: @escaping (LogEntry) -> Void) {
        self.closure = closure
    }
    
    override func hook(_ entry: LogEntry) {
        closure(entry)
    }
}

private final class HookBox<Hook: LogHook>: AbstractHook {
    
    private let hook: Hook
    
    init(_ hook: Hook) {
        self.hook = hook
    }
    
    override func hook(_ entry: LogEntry) {
        self.hook.hook(entry)
    }
}
