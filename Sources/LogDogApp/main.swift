import Foundation
import LogDog

let logger1 = Logger.sugar("com.v2ambition.App")

let logger2 = Logger(label: "com.v2ambition.DB") { label in

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]
    let jsonFormtter = LogFormatters.Encode(encoder)

    let text = AnyLogFormatter<Data, String>({ (record) -> String? in
        String(bytes: record.output, encoding: .utf8)
    })

    let sink = jsonFormtter.concat(text).schedule(on: DispatchQueue(label: "123"))
    return SugarLogHandler(label: label, sink: sink, appender: TextLogAppender.stdout)
}

func run(logger: Logger) {
    logger.t("POST /users", metadata: ["body": ["name": "秋"]])

    logger.d("got response", metadata: ["message": "ok"])

    logger.i("request success")

    logger.n("latency too long", metadata: ["latency": .any(100), "some": ["a": .any(1)]])

    logger.w("networking no cononection")

    logger.e("bad response", metadata: ["body": .any(10)])

    logger.c("can not connect to db")
}

run(logger: logger1)

// run(logger: logger2)

var stringify = LogStringify.default

print(Date())

if #available(OSX 10.12, *) {
    let fmt = ISO8601DateFormatter()
    print(fmt.string(from: Date()))
} else {
    // Fallback on earlier versions
}

dispatchMain()
