import Foundation
import LogDog

let loggerA = Logger.sugar("worker:a")

let loggerB = Logger(label: "worker:b") { label in

    let encoder = JSONEncoder()
    if #available(OSX 10.15, *) {
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    } else {
        // Fallback on earlier versions
    }

    let sink = LogSinks.firstly
        .hook(.date, .appName, .thread)
        .encode(encoder: encoder)
        .format {
            String(bytes: $0.output, encoding: .utf8)
        }

    return SugarLogHandler(label: label, sink: sink, appender: TextLogAppender.stdout)
}

func demo(_ logger: Logger) {
    logger.t("POST /users", metadata: ["body": ["name": "秋"]])

    logger.d("got response", metadata: ["message": "ok"])

    logger.i("request success")

    let date: Date? = Date()
    logger.n("latency too long", metadata: ["latency": .any(100), "some": ["date": .any(date as Any)]])

    logger.w("no connection")

    logger.e("bad response", metadata: ["url": .any("/me"), "status_code": .any(404)])

    logger.c("can not connect to db")
}

demo(loggerA)

dispatchMain()
