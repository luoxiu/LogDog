# LogDog

<a href="https://github.com/luoxiu/LogDog/actions">
  <img src="https://github.com/luoxiu/LogDog/workflows/Swift/badge.svg">
</a>

<div align="center">
    <br>
    <br>
    <strong>user-friendly logging</strong>
    <br>
    <br>
    <em><a href=https://github.com/apple/swift-log>apple/swift-log</a> api compatible</em>
</div>

## Usage

LogDog is designed to work out of the box, you can use the pre-configured logger anytime, anywhere:

```swift
sugar.debug("hi")

sugar.error("somethings went wrong")
```

Or, make a local copy and do some changes:


```swift
var logger = suggar
logger["path"] = "/me"

logger.debug("hi")
```

You can quickly create a logger with just a label, it will use the predefined log handler:

```swift
var logger = Logger.sugar("worker:a")
logger.level = .info

logger.info("hi")
```

### SugarLogHandler

The core component that makes this all work is `SugarLogHandler`.

The following code snippet shows how to create a `SugarLogHandler` and use it to bootstrap the logging system.

```swift
LoggingSystem.bootstrap { label in

    // ! to create your own `SugarLogHandler`, you need a `sink`, an `appender` and an optional `errorHandler`. 
    let sink = LogSinks.Builtin.short
    let appender = TextLogAppender.stdout
    let errorHandler = { error: Error in
        print("LogError: \(error)")
    }

    var handler = SugarLogHandler(label: label, sink: sink, appender: appender, errorHandler: errorHandler)

    // ! use dynamicMetadata to register values that are evaluted on logging.
    handler.dynamicMetadata["currentUserId"] = {
        AuthService.shared.userId
    }   
    
    return handler
}

let logger = Logger(label: "app")
logger.error("Something went wrong")
```

### Sink

Sinks process log records.

A sink can be a formatter, or a filter, a hook, or a chain of other sinks.

#### Formatter

You can create a formatter sink with just a closure.

```swift
let sink = LogSinks.firstly
    .format {
        "\($0.entry.level.uppercased) \($0.entry.message)\n"
    }
    
// Output:
//
//     DEBUG hello
```

Or use the built-in neat formatters directly.

```swift
let short = LogSinks.BuiltIn.short

// Output:
//
//     E: bad response
//     C: can not connect to db


let medium = LogSinks.BuiltIn.medium  // default sink for sugar loggers

// Output:
//
//     20:40:56.850 E/App main.swift.39: bad response url=/me, status_code=404
//     20:40:56.850 C/App main.swift.41: can not connect to db


let long = LogSinks.BuiltIn.long

// Output:
//
//     ╔════════════════════════════════════════════════════════════════════════════════
//     ║ 2020-11-15 20:46:31.157  App  ERROR     (main.swift:39  run(_:))
//     ╟────────────────────────────────────────────────────────────────────────────────
//     ║ bad response
//     ╟────────────────────────────────────────────────────────────────────────────────
//     ║ url=/me
//     ║ status_code=404
//     ╚════════════════════════════════════════════════════════════════════════════════
```

#### Filter

You can create a filter sink with just a closure.

```swift
let sink = LogSinks.firstly
    .filter {
        $0.entry.source != "LogDog"
    }
    
// logs from `LogDog` will not be output.
```

**DSL**

Or use the built-in expressive dsl to create one.

```swift
let sink = LogSinks.BuiltIn.short
    .when(.path)
    .contains("private")
    .deny
    
let sink = LogSinks.BuiltIn.short
    .when(.level)
    .greaterThanOrEqualTo(.error)
    .allow
```

#### Concat

Sinks are chainable, a `sink` can concatenate another `sink`.

```swift
let sink = sinkA + sinkB + sinkC // + sinkD + ...

// or
let sink = sinkA
    .concat(sinkB)
    .concat(sinkC)
    // .concat(sinkD) ...
```

LogDog ships with many commonly used operators.

**Prefix & Suffix**

```swift
let sink = LogSinks.BuiltIn.short
    .prefix("🎈 ")
    
// Output:
//
//     🎈 E: bad response


let sink = LogSinks.BuiltIn.short
    .suffix(" 🎈")
    
// Output:
//
//     E: bad response 🎈
```

**Encode**

```swift
let sink = LogSinks.firstly
    .encode(JSONEncoder())
```

**Crypto**

```swift
let sink = LogSinks.firstly
    .encode(JSONEncoder())
    .encrypt(using: key, cipher: .ChaChaPoly)
```

**Compress**


```swift
let sink = LogSinks.firstly
    .encode(JSONEncoder())
    .compress(.COMPRESSION_LZFSE)
```

#### Schedule

Sinks's processing can be time-consuming, if you don't want it to slow down your work, you can using `Scheduler` to make logging asynchronous.


```swift
let sink = LogSinks.firstly
    .sink(on: dispatchQueue) // or an operationQueue, or some other custom schedulers, for example, an eventLoop.
    .encode(JSONEncoder()) // time-consuming processing begins.
    .encrypt(using: key, cipher: .ChaChaPoly)
    .compress(.COMPRESSION_LZFSE)
```

#### Hook

Because of `Scheduler`, the logging may be asynchronous. 

It means that the sinking may be in a different context, 

You can use `hook` with `entry.parameters` to capture and pass the context.

```swift
private struct CustomSinkContext: LogParameterKey {
    typealias Value = CustomSinkContext

    let date = Date()
    let thread = LogHelper.thread
}

let customSink: AnyLogSink<Void, String> = AnyLogSink {

    // ! beforeSink: in the same context as the log generation.
    
    $0.parameters[CustomSinkContext.self] = .init()
} sink: { record, next in

    // ! sink: may not be in the same context as the log generation.

    record.sink(next: next) { (record) -> String? in
        guard let context = record.entry.parameters[CustomSinkContext.self] else {
            return nil
        }

        let time = LogHelper.format(context.date, using: "HH:mm:ss.SSS")
        let thread = context.thread
        
        // ...
    }
}
```

**Please note, when using `encode`, parameters with string as key will also be encoded.**

```swift
LogSinks.firstly
  .hook { 
     $0.parameters["currentUserId"] = AuthService.shared.userId
  }
  .hook(.appName, .appVersion, .date) /* , ..., a lot of built-in hooks */
  .encode(JSONEncoder())
  
/*
{
  "label": "app",
  "level": "debug",
  "metadata": {
    // ...
  }
  // ...
  "currentUserId": "1",
  "appName": "LogDog",
  "appVersion": "0.0.1",
  "date": "2020-11-19T01:12:37.001Z"
}
 */
```


### Appender

Appenders are destinations of log records.

#### Built-in Appenders

**OSLogAppender**

Append strings to the underlying `OSLog`.

```swift
let appender = OSLogAppender(osLog)
```

**TextLogAppender**

Append strings to the underlying `TextOutputStream`.

```swift
let appender = TextLogAppender(stream)

let stdout = TextLogAppender.stdout
let stderr = TextLogAppender.stderr
```

**MultiplexLogAppender**

Append outputs to the underlying appenders.

```swift
// when `concurrent` is `true`, a dispatch group is used to make the appending of all appenders parallel. 
let appender = MultiplexLogAppender(concurrent: true, a, b, c, d/*, ...*/)
```

**FileLogAppender**

WIP

- [ ] async
- [ ] auto rotate
- [ ] ...


## Community

In addition to the sinks/appenders mentioned above, you can also find more integrations at [LogDogCommunity](https://github.com/LogDogCommunity)!

### LogDogChalk

Color the output of LogDog.

![](https://github.com/LogDogCommunity/LogDogChalk/raw/master/demo.png)

### LogDogCryptoSwift

Encrypt the output of LogDog.

### LogDogCocoaLumberjack

Append the output of LogDog to CocoaLumberjack.

**Don't have the sink/appender you want? Contributions are welcome!**

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/luoxiu/LogDog.git", from: "0.2.0"),
```

### CocoaPods

```ruby
pod 'LogDog', '~> 0.2.0'
```

