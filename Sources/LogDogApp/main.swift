import Foundation
import LogDog


let logger1 = Logger.sugar("com.aftership.App")

let logger2 = Logger(label: "json") { label in

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]
    let jsonFormtter = EncoderLogFormatter(encoder)

    let text = AnyLogFormatter<Data, String>({ (record) -> String? in
        String(bytes: record.output, encoding: .utf8)
    })

    return SugarLogHandler(label: label, formatter: jsonFormtter + text, appender: TextLogAppender.stdout)
}

func run(logger: Logger) {
    logger.trace("POST /users", metadata: ["body": ["name": "秋"]])

    logger.debug("got response", metadata: ["message": "ok"])

    logger.info("request success")

    logger.notice("latency too long", metadata: ["latency": .any(100), "some": ["a": .any(1)]])

    logger.warning("networking no cononection")

    logger.error("bad response", metadata: ["body": .any(10)])

    logger.critical("can not connect to db")
}

let timer = DispatchSource.makeTimerSource()
timer.setEventHandler {
    run(logger: logger1)

    run(logger: logger2)
}
timer.schedule(deadline: .now(), repeating: 5, leeway: .seconds(0))
timer.resume()

dispatchMain()

