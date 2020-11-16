import XCTest
@testable import LogDog

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
        queue.immediate.schedule {
            i += 1
        }
        
        XCTAssertEqual(i, 1)
    }
}
