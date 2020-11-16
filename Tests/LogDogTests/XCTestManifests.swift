#if !canImport(ObjectiveC)
import XCTest

extension AnyLogAppenderTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AnyLogAppenderTests = [
        ("testAppender", testAppender),
        ("testBody", testBody),
    ]
}

extension LazyTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__LazyTests = [
        ("testLazy", testLazy),
    ]
}

extension LogSchedulerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__LogSchedulerTests = [
        ("testDispatchQueue", testDispatchQueue),
        ("testDispatchQueueImmediate", testDispatchQueueImmediate),
    ]
}

extension LogStringifyTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__LogStringifyTests = [
        ("testClear", testClear),
        ("testDefault", testDefault),
        ("testMetadataValueAny", testMetadataValueAny),
        ("testSet", testSet),
        ("testSetAndUse", testSetAndUse),
        ("testUse", testUse),
    ]
}

extension MemoryLogAppenderTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__MemoryLogAppenderTests = [
        ("testAppend", testAppend),
    ]
}

extension MultiplexLogAppenderTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__MultiplexLogAppenderTests = [
        ("testAppend", testAppend),
    ]
}

extension TestLogAppenderTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TestLogAppenderTests = [
        ("testAppend", testAppend),
    ]
}

extension UnwrapTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__UnwrapTests = [
        ("testUnwrap", testUnwrap),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyLogAppenderTests.__allTests__AnyLogAppenderTests),
        testCase(LazyTests.__allTests__LazyTests),
        testCase(LogSchedulerTests.__allTests__LogSchedulerTests),
        testCase(LogStringifyTests.__allTests__LogStringifyTests),
        testCase(MemoryLogAppenderTests.__allTests__MemoryLogAppenderTests),
        testCase(MultiplexLogAppenderTests.__allTests__MultiplexLogAppenderTests),
        testCase(TestLogAppenderTests.__allTests__TestLogAppenderTests),
        testCase(UnwrapTests.__allTests__UnwrapTests),
    ]
}
#endif
