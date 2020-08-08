import Foundation

private let fileManager = FileManager.default

public typealias Path = String

public protocol FileLogOutputStreamDelegate {
    
    func stream(_ stream: FileLogOutputStream, fileToOutput logEntry: ProcessedLogEntry<Data>, currentFile: Path?) throws -> Path?
}

open class FileLogOutputStream: LogOutputStream {
    
    public typealias Output = Data
    
    public let delegate: FileLogOutputStreamDelegate
    
    public let queue = DispatchQueue(label: "com.v2ambition.LogDog.FileLogOutputStream")
    
    private var currentFile: Path?
    
    public init(delegate: FileLogOutputStreamDelegate) {
        self.delegate = delegate
    }
    
    open func output(_ logEntry: ProcessedLogEntry<Data>) throws {
        let data = logEntry.output
        
        if data.isEmpty { return }
        
        let body = { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let file = try self.delegate.stream(self, fileToOutput: logEntry, currentFile: self.currentFile) else {
                return
            }
            
            self.currentFile = file
            
            guard let outputStream = OutputStream(toFileAtPath: file, append: true) else {
                return
            }
            
            outputStream.open()
            
            _  = data.withUnsafeBytes { pointer -> Int in
                let address = pointer.bindMemory(to: UInt8.self).baseAddress!
                return outputStream.write(address, maxLength: data.count)
            }
            
            outputStream.close()
            
            if let error = outputStream.streamError {
                throw error
            }
        }
        
        try queue.sync(execute: body)
    }
}

extension FileLogOutputStream {
    
    public static let defaultLogsDirectory: String = {
        #if os(iOS) || os(tvOS) || os(watchOS)
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return path.ns.appendingPathComponent("Logs")
        #else
        let processName = ProcessInfo.processInfo.processName
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? NSTemporaryDirectory()
        return path.ns.appendingPathComponent("Logs").ns.appendingPathComponent(processName)
        #endif
    }()
}

open class AbstractRotator: FileLogOutputStreamDelegate {
    
    public let directory: String
    public let directoryCountLimit: Int
    public let directorySizeLimit: UInt64
    
    public init?(
        directory: String = FileLogOutputStream.defaultLogsDirectory,
        directoryCountLimit: Int = 5,
        directorySizeLimit: UInt64 = 20 * 1024 * 1024
    ) {
        let directory = directory
        
        let (exists, isDirectory) = directory.exists
        if exists {
            guard isDirectory, directory.isWritableFile else {
                return nil
            }
        } else {
            guard directory.createDirectory() else {
                return nil
            }
        }
        
        self.directory = directory
        self.directoryCountLimit = directoryCountLimit
        self.directorySizeLimit = directorySizeLimit
        
        deleteOldFiles()
    }
    
    open func deleteOldFiles() {
        let cmp = { (a: String, b: String) -> Bool in
            guard let a = a.modificationDate, let b = b.modificationDate else { return false }
            return a > b
        }
        
        let directory = self.directory
        let directoryCountLimit = self.directoryCountLimit
        let directorySizeLimit = self.directorySizeLimit
        
        let body = {
            guard let files = directory.contents?.sorted(by: cmp) else {
                return
            }
            
            var firstIndexToDelete = -1
            
            if directorySizeLimit != .max {
                var size: UInt64 = 0
                for (index, file) in files.enumerated() {
                    size += (file.size ?? 0)
                    
                    if size > directorySizeLimit {
                        firstIndexToDelete = index
                        break
                    }
                }
            }
            
            if firstIndexToDelete == -1 {
                firstIndexToDelete = directoryCountLimit
            } else {
                firstIndexToDelete = min(directoryCountLimit, firstIndexToDelete)
            }
            
            while firstIndexToDelete < files.count {
                _ = files[firstIndexToDelete].delete()
                firstIndexToDelete += 1
            }
        }
        
        body()
    }
    
    open func stream(_ stream: FileLogOutputStream, fileToOutput logEntry: ProcessedLogEntry<Data>, currentFile: Path?) throws -> Path? {
        nil
    }
}

open class DailyRotator: AbstractRotator {
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    open override func stream(_ stream: FileLogOutputStream, fileToOutput logEntry: ProcessedLogEntry<Data>, currentFile: Path?) throws -> Path? {
        let date = logEntry.rawLogEntry.date
        let filename = Self.formatter.string(from: date) + ".log"
        
        if let currentFile = currentFile, currentFile.filename == filename {
            return currentFile
        }
        
        let file = NSString(string: directory).appendingPathComponent(filename)
        if file.exists.exists {
            return file
        }
        
        guard file.create() else {
            return nil
        }
        
        deleteOldFiles()
        
        return file
    }
}

private extension Path {
    
    var filename: String {
        ns.lastPathComponent
    }
    
    var contents: [Path]? {
        try? fileManager
            .contentsOfDirectory(atPath: self)
    }
    
    var attributes: [FileAttributeKey: Any]? {
        try? fileManager.attributesOfItem(atPath: self)
    }
     
    var modificationDate: Date? {
        attributes?[.modificationDate] as? Date
    }
    
    var size: UInt64? {
        (attributes?[.size] as? NSNumber)?.uint64Value
    }
    
    var exists: (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false
        let exist = fileManager.fileExists(atPath: self, isDirectory: &isDirectory)
        return (exist, isDirectory.boolValue)
    }
    
    var isWritableFile: Bool {
        fileManager.isWritableFile(atPath: self)
    }
    
    func createDirectory() -> Bool {
        do {
            try fileManager.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    func create() -> Bool {
        fileManager.createFile(atPath: self, contents: Data(), attributes: nil)
    }
    
    func delete() -> Bool {
        do {
            try fileManager.removeItem(atPath: self)
            return true
        } catch {
            return false
        }
    }
    
}
