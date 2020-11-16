@testable import LogDog
import XCTest

class HooksTests: XCTestCase {
    func testHook() {
        var entry = LogEntry.fake()

        let hook = LogHook { entry in
            entry.parameters[0] = 0
        }

        hook.hook(&entry)

        XCTAssertEqual(entry.parameters[0] as? Int, 0)
    }

    func testMultipleHooks() {
        var entry = LogEntry.fake()

        let hookA = LogHook { entry in
            entry.parameters[0] = 0
        }
        let hookB = LogHook { entry in
            entry.parameters[1] = 1
        }

        let hook = LogHook([hookA, hookB])

        hook.hook(&entry)

        XCTAssertEqual(entry.parameters[0] as? Int, 0)
        XCTAssertEqual(entry.parameters[1] as? Int, 1)
    }
}
