@testable import LogDog
import XCTest

class LogParametersTests: XCTestCase {
    func testParameters() {
        var parameters = LogParameters()

        parameters[1] = 1

        XCTAssertEqual(parameters[1] as? Int, 1)

        parameters["a"] = "a"

        XCTAssertEqual(parameters["a"] as? String, "a")
    }

    func testParameterKey() {
        struct Key: LogParameterKey {
            typealias Value = Self

            let num = 0
        }

        var parameters = LogParameters()

        parameters[Key.self] = Key()

        XCTAssertEqual(parameters[Key.self]?.num, 0)

        parameters[Key.self] = nil

        XCTAssertNil(parameters[Key.self])
    }
}
