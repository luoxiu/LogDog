# LogDog

<a href="https://github.com/luoxiu/LogDog/actions">
  <img src="https://github.com/luoxiu/LogDog/workflows/Swift/badge.svg">
</a>

<div align="center">
    <br>
    <br>
    <strong>Friendly logging.</strong>
    <br>
    <br>
</div>

## Usage

### Sink

#### Format

```swift
let sink = LogSinks.firstly
    .format {
        "\($0.entry.level.uppercased) \($0.entry.message)\n"
    }
    
// Output:
//
//     DEBUG hello
```

##### Built-in Formatters

```swift
let short = LogSinks.BuiltIn.short

// Output:
//
//     E: bad response
//     C: can not connect to db


let medium = LogSinks.BuiltIn.medium

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

**Compress**

```swift
let sink = LogSinks.firstly
    .encode(JSONEncoder())
    .encrypt(using: key, cipher: .ChaChaPoly)
```

**Crypto**

```swift
let sink = LogSinks.firstly
    .encode(JSONEncoder())
    .compress(.COMPRESSION_LZFSE)
```

#### Filter

```swift
let sink = LogSinks.firstly
    .filter {
        $0.entry.source != "LogDog"
    }
    
// logs from `LogDog` won't be outputted.
```

**DSL**

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

```swift
let sink = LogSinks.Builtin.short
    .prefix("🎈 ")
    .suffix(" 🎈")
    .when(.path).contains("private").deny
    // ...
    
let sink = LogSinks.firstly
    .encode(JSONEncoder())
    .encrypt(using: key, cipher: .ChaChaPoly)
    .compress(.COMPRESSION_LZFSE)
```

#### Schedule

```swift
let sink = LogSinks.firstly
    .sink(on: dispatchQueue)
    .encode(JSONEncoder())
    .encrypt(using: key, cipher: .ChaChaPoly)
    .compress(.COMPRESSION_LZFSE)
```

#### Hook

Because of the existence of the schedule, the sinking may be asynchronous.
So you should not get the context when sinking.

You should use `hook` with `entry.parameters` to capture and store the context.

```swift
private struct CustomSinkContext: LogParameterKey {
    typealias Value = CustomSinkContext

    let date = Date()
    let thread = LogHelper.thread
}

let customSink: AnyLogSink<Void, String> = .init {
    $0.parameters[CustomSinkContext.self] = .init()
} sink: { record, next in
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

### Appender

#### Built-in Formatters

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
let appender = MultiplexLogAppender(concurrent: true, a, b, c, d/*, ...*/)
```

**FileLogAppender(WIP)**

### SugarLogHandler

Create a `SugarLogHandler`.

```swift
let sink = LogSinks.Builtin.short
let appender = TextLogAppender.stdout

var handler = SugarLogHandler(label: label, sink: sink, appender: appender) { error in
    print("error: \(error)")
}

handler.dynamicMetadata["userId"] = {
    AuthService.shared.userId
}
```

Create a logger with predefined log handler.

```swift
let logger = Logger.sugar("worker:a")
```

Use the predefined logger.

```swift
sugar.debug("hi")
```

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
.package(url: "https://github.com/apple/swift-log.git", from: "0.2.0"),
```

### CocoaPods

```ruby
pod 'LogDog', '~> 0.2.0'
```

