
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
@_functionBuilder
public struct LogFormatterBuilder {
    
    public static func buildBlock<F>(_ formatter: F) -> F where F: LogFormatter {
        return formatter
    }
    
    public static func buildBlock<F1, F2>(_ f1: F1, _ f2: F2) -> AnyLogFormatter<F1.I, F2.O> where F1: LogFormatter, F2: LogFormatter, F1.O == F2.I {
        let _f1 = AnyLogFormatter<F1.I, F1.O>(f1)
        let _f2 = AnyLogFormatter<F2.I, F2.O>(f2)
        return .init {
            try _f2.format(_f1.format($0))
        }
    }
    public static func buildBlock<F1, F2, F3>(_ f1: F1, _ f2: F2, _ f3: F3) -> AnyLogFormatter<F1.I, F3.O> where F1: LogFormatter, F2: LogFormatter, F3: LogFormatter, F1.O == F2.I, F2.O == F3.I {
        buildBlock(
            buildBlock(f1, f2), f3
        )
    }
    public static func buildBlock<F1, F2, F3, F4>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4) -> AnyLogFormatter<F1.I, F4.O> where F1: LogFormatter, F2: LogFormatter, F3: LogFormatter, F4: LogFormatter, F1.O == F2.I, F2.O == F3.I, F3.O == F4.I {
        buildBlock(
            buildBlock(
                buildBlock(f1, f2), f3
            ), f4
        )
    }
    public static func buildBlock<F1, F2, F3, F4, F5>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5) -> AnyLogFormatter<F1.I, F5.O> where F1: LogFormatter, F2: LogFormatter, F3: LogFormatter, F4: LogFormatter, F5: LogFormatter, F1.O == F2.I, F2.O == F3.I, F3.O == F4.I, F4.O == F5.I {
        buildBlock(
            buildBlock(
                buildBlock(
                    buildBlock(f1, f2), f3
                ), f4
            ), f5
        )
    }
    public static func buildBlock<F1, F2, F3, F4, F5, F6>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6) -> AnyLogFormatter<F1.I, F6.O> where F1: LogFormatter, F2: LogFormatter, F3: LogFormatter, F4: LogFormatter, F5: LogFormatter, F6: LogFormatter, F1.O == F2.I, F2.O == F3.I, F3.O == F4.I, F4.O == F5.I, F5.O == F6.I {
        buildBlock(
            buildBlock(
                buildBlock(
                    buildBlock(
                        buildBlock(f1, f2), f3
                    ), f4
                ), f5
            ), f6)
    }
}
