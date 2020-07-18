import Foundation

public final class FileLogOutputStream: LogOutputStream {
    
    private static let ioQueuesLock = NSLock()
    private static var ioQueues: [Path: DispatchQueue] = [:]
    
    private static func ioQueue(for path: Path) -> DispatchQueue {
        ioQueuesLock.lock()
        defer { ioQueuesLock.unlock() }
        
        if let queue = ioQueues[path] { return queue }
        
        let queue = DispatchQueue(label: "com.v2ambition.LogDog.ioQueue.\(path.resolved)", qos: .utility)
        ioQueues[path] = queue
        return queue
    }
    
    public typealias Output = Data

    public let sync: Bool
    
    public let directory: Path

    public let delimiter: Data
    
    public let rotator: Rotator
    public let cleaner: Cleaner
    
    public private(set) var currentFile: DataFile?
    private var currentOutputStream: OutputStream?
    
    private var files: [Path] = []
    private var size: UInt64 = 0
    
    private let ioQueue: DispatchQueue
    
    public init(sync: Bool = false,
                directory: Path = FileLogOutputStream.defaultDirectory,
                delimiter: Data = Data(),
                rotator: Rotator = .rotateByDay,
                cleaner: Cleaner = .cleanBy(countLimit: .max, sizeLimit: 10 * 1025 * 1024)
    ) {
        
        self.sync = sync
        
        let directory = directory.resolved
        self.directory = directory
        
        self.delimiter = delimiter
        
        self.rotator = rotator
        self.cleaner = cleaner
        
        let ioQueue = FileLogOutputStream.ioQueue(for: directory)
        self.ioQueue = ioQueue
        
        ioQueue.sync {
            if directory.exists {
                guard directory.isDirectory else {
                    return
                }
                
                let files = directory
                    .children()
                    .filter {
                        $0.pathExtension == "log"
                    }
                    .sorted { a, b in
                        if let dateA = a.modificationDate, let dateB = b.modificationDate {
                            return dateA < dateB
                        }
                        return true
                    }
                self.files = files
                self.size = files.reduce(into: UInt64()) {
                    if let size = $1.fileSize { $0 += size }
                }
            } else {
                try? directory.createDirectory()
            }
        }
    }
    
    public func write(_ logEntry: ProcessedLogEntry<Data>) throws {
        let data = logEntry.output
        
        guard data.count > 0 else { return }
        
        let body = { [weak self] in
            guard
                let self = self,
                let file = self.rotator.rorate(self, logEntry)
            else {
                return
            }
            
            if file != self.currentFile {
                if !file.exists {
                    do {
                        try file.create()
                        
                        self.files.append(file.path)
                        self.cleaner.fileDidCreate(self)
                    } catch {
                        return
                    }
                }
                
                self.currentFile = file
                
                self.currentOutputStream?.close()
                self.currentOutputStream = file.outputStream(append: true)
            }
            
            guard let outputStream = self.currentOutputStream else {
                return
            }
            
            outputStream.open()
            
            var data = data
            if self.delimiter.count > 0 {
                data.append(self.delimiter)
            }
            
            let written = data.withUnsafeBytes { pointer -> Int in
                let address = pointer.bindMemory(to: UInt8.self).baseAddress!
                return outputStream.write(address, maxLength: data.count)
            }
            
            self.size += UInt64(written)
            self.cleaner.logEntryDidWrite(self)
        }
        
        if sync {
            ioQueue.sync { body() }
        } else {
            ioQueue.async {
                body()
            }
        }
    }
    
    public func flush() {
        ioQueue.sync { }
    }
    
    deinit {
        flush()
    }
}

extension FileLogOutputStream {
    
    public static let defaultDirectory: Path = {
        #if os(iOS) || os(tvOS) || os(watchOS)
        return Path.userCaches + ".logdog"
        #else
        let processName = ProcessInfo.processInfo.processName
        return Path.userHome + ".logdog" + processName
        #endif
    }()
    
    public static let newLineDelimiter = "\n".data(using: .utf8)!

    public struct Rotator {
        public let rorate: (FileLogOutputStream, ProcessedLogEntry<Data>) -> DataFile?
        
        public init(_ file: @escaping (FileLogOutputStream, ProcessedLogEntry<Data>) -> DataFile?) {
            self.rorate = file
        }
        
        private static let rotateByDayFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        public static var rotateByDay: Rotator {
            Rotator { outputStream, logEntry in
                let dateString = rotateByDayFormatter.string(from: logEntry.rawLogEntry.date)
                let filename = "\(logEntry.rawLogEntry.label).\(dateString).log"
                
                if filename != outputStream.currentFile?.name {
                    return DataFile(path: outputStream.directory + filename)
                }
                
                return outputStream.currentFile
            }
        }
        
        public static func rorateBySize(_ sizeLimit: UInt64) -> Rotator {
            Rotator { outputStream, logEntry in
                if let size = outputStream.currentFile?.size, size < sizeLimit {
                    return outputStream.currentFile
                }
                
                let time = logEntry.rawLogEntry.date.iso8601String
                let filename = "\(logEntry.rawLogEntry.label).\(time).log"

                return DataFile(path: outputStream.directory + filename)
            }
        }
    }
    
    public struct Cleaner {
        
        public let fileDidCreate: (FileLogOutputStream) -> Void
        public let logEntryDidWrite: (FileLogOutputStream) -> Void
        
        public init(_ fileDidCreate: @escaping (FileLogOutputStream) -> Void,
                    _ logEntryDidWrite: @escaping (FileLogOutputStream) -> Void) {
            self.fileDidCreate = fileDidCreate
            self.logEntryDidWrite = logEntryDidWrite
        }
        
        public static func cleanBy(countLimit: Int, sizeLimit: UInt64) -> Cleaner {
            Cleaner({ outputStream in
                outputStream.cleanByCount(countLimit)
            }, { outputStream in
                outputStream.cleanBySize(sizeLimit)
            })
        }
    }
    
    private func cleanByCount(_ countLimit: Int) {
        let count = files.count - countLimit
        if count > 0 {
            let trash = files[safe: 0..<count]
            
            DispatchQueue.global().async {
                trash.forEach {
                    try? $0.deleteFile()
                }
            }
        }
    }
    
    private func cleanBySize(_ sizeLimit: UInt64) {
        var trash: [Path] = []
        while size > sizeLimit, files.count > 0 {
            let path = files.removeFirst()
            trash.append(path)
            size -= (path.fileSize ?? 0)
        }
        
        if trash.count > 0 {
            DispatchQueue.global().async {
                trash.forEach {
                    try? $0.deleteFile()
                }
            }
        }
    }
}
