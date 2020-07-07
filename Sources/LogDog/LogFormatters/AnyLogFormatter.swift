/// `some` is only available in iOS 13.0.0 / macOS 10.15.0 or newer.
public struct AnyLogFormatter<I, O>: LogFormatter {
    
    private var box: Box<I, O>
    
    public init(_ format: @escaping (FormattedLogEntry<I>) throws -> FormattedLogEntry<O>) {
        box = ClosureBox(format)
    }
    
    public init<F: LogFormatter>(_ formatter: F) where F.I == I, F.O == O {
        box = FormatterBox(formatter)
    }
    
    public func format(_ log: FormattedLogEntry<I>) throws -> FormattedLogEntry<O> {
        try box.format(log)
    }
}

extension AnyLogFormatter {
    
    private class Box<I, O>: LogFormatter {
        func format(_ log: FormattedLogEntry<I>) throws -> FormattedLogEntry<O> {
            fatalError()
        }
    }
    
    private final class ClosureBox<I, O>: Box<I, O> {
        private let closure: (FormattedLogEntry<I>) throws -> FormattedLogEntry<O>
        
        init(_ closure: @escaping (FormattedLogEntry<I>) throws -> FormattedLogEntry<O>) {
            self.closure = closure
        }
        
        override func format(_ log: FormattedLogEntry<I>) throws -> FormattedLogEntry<O> {
            try closure(log)
        }
    }
    
    private final class FormatterBox<Formatter: LogFormatter>: Box<Formatter.I, Formatter.O> {
        
        private var formatter: Formatter
        
        init(_ formatter: Formatter) {
            self.formatter = formatter
        }
        
        override func format(_ log: FormattedLogEntry<I>) throws -> FormattedLogEntry<O> {
            try formatter.format(log)
        }
    }
}
