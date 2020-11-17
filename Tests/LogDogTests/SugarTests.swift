@testable import LogDog
import XCTest

final class SugarTests: XCTestCase {
    func testMetadata() {
        let appender = MemoryLogAppender<String>()

        var ctx = "x"

        let logger = Logger(label: "log") { label -> LogHandler in
            var handler = SugarLogHandler(label: label,
                                          sink: LogSinks.BuiltIn.medium,
                                          appender: appender)
            handler.metadata["a"] = "a"

            handler.dynamicMetadata["b"] = {
                .string(ctx)
            }

            return handler
        }

        ctx = "b"

        logger.d("hello", metadata: ["c": "c"])

        guard let record = appender.snapshot.first else {
            XCTFail()
            return
        }

        XCTAssertEqual(record.entry.metadata["a"], .string("a"))
        XCTAssertEqual(record.entry.metadata["b"], .string("b"))
        XCTAssertEqual(record.entry.metadata["c"], .string("c"))
    }
}
