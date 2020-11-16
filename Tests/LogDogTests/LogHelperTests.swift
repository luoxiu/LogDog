@testable import LogDog
import XCTest

class LogHelperTests: XCTestCase {
    func testDataFormat() {
        let data = Data(repeating: 0, count: 1000 * 1000)
        XCTAssertEqual(LogHelper.format(data, using: .file), "1 MB")
        XCTAssertEqual(LogHelper.format(data, using: .memory), "977 KB")
    }

    func testDateFormat() {
        let components = DateComponents(calendar: Calendar(identifier: .iso8601),
                                        year: 2000,
                                        month: 1,
                                        day: 1,
                                        hour: 0,
                                        minute: 0,
                                        second: 0)
        guard let date = components.date else {
            XCTFail()
            return
        }

        XCTAssertEqual(LogHelper.format(date, using: "yyyy-MM-dd HH:mm:ss.SSS"), "2000-01-01 00:00:00.000")
    }

    func testBasename() {
        let path = "/Users/quentin/some.txt"

        XCTAssertEqual(LogHelper.basename(of: path, withExtensions: true), "some.txt")
        XCTAssertEqual(LogHelper.basename(of: path, withExtensions: false), "some")
    }

    func testDispatchQueue() {
        let label = "log"
        let queue = DispatchQueue(label: label)

        queue.sync {
            XCTAssertEqual(LogHelper.currentDispatchQueueLabel, label)
        }
    }
}
