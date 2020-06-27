import XCTest
import Logging
@testable import LogDog

final class LogTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(0, 0)
        
        // let logger = Logger(label: "log.test")
        
        Thread.callStackSymbols.forEach {
            print($0)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
