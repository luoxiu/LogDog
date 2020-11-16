import LogDog

extension LogEntry {
    static func fake() -> LogEntry {
        .init(label: "label",
              level: .critical,
              message: "message",
              metadata: [:],
              source: "source",
              file: "file",
              function: "function",
              line: 0)
    }
}
