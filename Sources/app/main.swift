import Foundation
import LogDog

let logger1: Logger = {
    let formatter = BoxedTextLogFormatter(
        showDate: true,
        showThreadInfo: true,
        methodCount: 2
    )
    +++ ColorLogFormatter()
    
    let outputStream = StdoutLogOutputStream()
    
    return Logger(label: "app",
                  level: .trace,
                  metadata: [:],
                  formatter: formatter,
                  outputStream: outputStream)
}()

var logger2: Logger = {
    let formatter = StopwatchLogFormatter()
        +++ ColorLogFormatter()
    
    let outputStream = StdoutLogOutputStream()
    
    return Logger(label: "app",
        level: .trace,
        metadata: [:],
        formatter: formatter,
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

//main()
//
//RunLoop.current.run()

let m = FileManager.default

func cleanup(_ path: String) {
    let url = NSString(string: path).resolvingSymlinksInPath
    print(url)
//    while let e = m.enumerator(atPath: dir)?.nextObject() {
//        print(e)
//    }
}

cleanup("./Sources")

