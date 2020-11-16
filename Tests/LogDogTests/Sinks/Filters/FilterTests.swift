@testable import LogDog
import XCTest

class FilterTests: XCTestCase {
    func testFilter() {
        let sink = LogSinks.firstly
            .format {
                String(describing: $0.entry.message)
            }
            .filter {
                !$0.output.contains("x")
            }

        let appender = MemoryLogAppender<String>()

        let logger = Logger(label: "app") {
            SugarLogHandler(label: $0,
                            sink: sink,
                            appender: appender)
        }

        for c in "abcxyz" {
            logger.d("\(c)")
        }

        XCTAssertEqual(appender.snapshot.map { $0.output }.joined(),
                       "abcyz")
    }

    func testMatch() {
        let sink = LogSinks.firstly
            .format {
                String(describing: $0.entry.message)
            }
            .when(.level).greaterThanOrEqualTo(.error).allow

        let appender = MemoryLogAppender<String>()

        let logger = Logger(label: "app") {
            SugarLogHandler(label: $0,
                            sink: sink,
                            appender: appender)
        }

        logger.d("d")
        logger.i("i")
        logger.e("e")
        logger.c("c")

        XCTAssertEqual(appender.snapshot.map { $0.output }.joined(),
                       "ec")
    }
}
