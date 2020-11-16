@testable import LogDog
import XCTest

class LogSchedulerTests: XCTestCase {
    func testDispatchQueue() {
        let label = "a"
        let queue = DispatchQueue(label: label)

        let expect = XCTestExpectation()

        queue.schedule {
            XCTAssertEqual(LogHelper.currentDispatchQueueLabel, label)

            expect.fulfill()
        }

        wait(for: [expect], timeout: .greatestFiniteMagnitude)
    }

    func testDispatchQueueImmediate() {
        let queue = DispatchQueue(label: "a")

        var i = 0

        for _ in 0 ..< 100 {
            queue.immediate.schedule {
                i += 1
            }
        }

        XCTAssertEqual(i, 100)
    }

    func testOpeationQueue() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let expect = XCTestExpectation()

        queue.schedule {
            XCTAssert(OperationQueue.current === queue)

            expect.fulfill()
        }

        wait(for: [expect], timeout: .greatestFiniteMagnitude)
    }

    func testOperationQueueImmediate() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        var i = 0

        for _ in 0 ..< 100 {
            queue.immediate.schedule {
                i += 1
            }
        }

        XCTAssertEqual(i, 100)
    }
}
