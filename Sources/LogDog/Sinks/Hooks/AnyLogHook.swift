public extension LogHook {
    func eraseToAnyLogHook() -> AnyLogHook<Input> {
        .init(self)
    }
}

public struct AnyLogHook<Input>: LogHook {
    
    public typealias Output = Input
    
    private let hook: AbstractHook<Input>
    
    public init<Hook: LogHook>(_ hook: Hook) where Hook.Input == Input {
        self.hook = HookBox(hook)
    }
    
    public init(_ hook: @escaping (LogEntry) throws -> Void) {
        self.hook = ClosureBox(hook)
    }
    
    public func hook(_ entry: LogEntry) throws {
        try hook.hook(entry)
    }
}

private class AbstractHook<Input>: LogHook {
    typealias Output = Input
    
    func hook(_ entry: LogEntry) throws {
        fatalError()
    }
}

private final class ClosureBox<Input>: AbstractHook<Input> {
    
    private let hook: (LogEntry) throws -> Void
    
    init(_ hook: @escaping (LogEntry) throws -> Void) {
        self.hook = hook
    }
    
    override func hook(_ entry: LogEntry) throws {
        try hook(entry)
    }
}

private final class HookBox<Hook: LogHook>: AbstractHook<Hook.Input> {
    
    private let hook: Hook
    
    init(_ hook: Hook) {
        self.hook = hook
    }
    
    override func hook(_ entry: LogEntry) throws {
        try self.hook.hook(entry)
    }
    
    func beforeSink(_ entry: LogEntry) {
        hook.beforeSink(entry)
    }

    func sink(_ record: LogRecord<Hook.Input>, next: @escaping (Result<LogRecord<Hook.Output>?, Error>) -> Void) {
        hook.sink(record, next: next)
    }
}
