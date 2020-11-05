public protocol LogHook {
    func hook(_ entry: LogEntry) -> Void
}
