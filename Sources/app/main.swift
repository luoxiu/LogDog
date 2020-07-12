import Foundation
import LogDog

let logger1: Logger = {
    let processor = BoxedTextLogProcessor(
        showDate: true,
        showThreadInfo: true,
        methodCount: 100
    )
    + ColorLogProcessor()
    
    let outputStream = StdoutLogOutputStream()
    
    return Logger(label: "app",
                  level: .trace,
                  metadata: [:],
                  processor: processor,
                  outputStream: outputStream)
}()

var logger2: Logger = {
    let processor = StopwatchLogProcessor() + ColorLogProcessor()
    
    let outputStream = StdoutLogOutputStream()
    
    return Logger(label: "app",
        level: .trace,
        metadata: [:],
        processor: processor,
        outputStream: outputStream)
}()


func run(logger: Logger) {
    logger.trace("POST /users", metadata: ["body": ["name": "秋"]])

    logger.debug("got response", metadata: ["message": "ok"])

    logger.info("request success")

    logger.notice("latency too long", metadata: ["latency": .any(100), "some": ["a": .any(1)]])

    logger.warning("networking no cononection")

    logger.error("bad response", metadata: ["body": .any(10)])

    logger.critical("can not connect to db")
}

func main() {
    run(logger: logger1)
    run(logger: logger2)
}

main()
