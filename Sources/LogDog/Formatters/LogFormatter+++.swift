infix operator +++ : AdditionPrecedence
public func +++<F1, F2>(_ f1: F1, _ f2: F2) -> AnyLogFormatter<F1.I, F2.O> where F1: LogFormatter, F2: LogFormatter, F1.O == F2.I {
    let _f1 = AnyLogFormatter<F1.I, F1.O>(f1)
    let _f2 = AnyLogFormatter<F2.I, F2.O>(f2)
    return .init {
        try _f2.format(_f1.format($0))
    }
}

