import Foundation

private let fileManager = FileManager.default

public protocol FileLogOutputStreamDelegate {
    
    func stream(_ stream: FileLogOutputStream, fileToOutput logEntry: ProcessedLogEntry<Data>, currentFile: URL?) throws -> URL?
}

open class FileLogOutputStream: LogOutputStream {
    
    public typealias Output = Data
    
    public let delegate: FileLogOutputStreamDelegate
    
    public let queue = DispatchQueue(label: "com.v2ambition.LogDog.FileLogOutputStream")
    
    private var currentFile: URL?
    
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
            
            guard let outputStream = OutputStream(toFileAtPath: file.absoluteString, append: true) else {
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
    
    public static let defaultDirectory: URL = {
        #if os(iOS) || os(tvOS) || os(watchOS)
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let cacheURL = URL(fileURLWithPath: cachePath)
        return cacheURL.appendingPathComponent("Logs", isDirectory: true)
        #else
        let processName = ProcessInfo.processInfo.processName
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let libraryURL = URL(fileURLWithPath: libraryPath, isDirectory: true)
        return libraryURL.appendingPathComponent("Logs", isDirectory: true).appendingPathComponent(processName)
        #endif
    }()
}

open class AbstractRotator: FileLogOutputStreamDelegate {
    
    public let directory: URL
    public let directoryCountLimit: Int
    public let directorySizeLimit: UInt64
    
    public init?(
        directory: URL = FileLogOutputStream.defaultDirectory,
        directoryCountLimit: Int = 5,
        directorySizeLimit: UInt64 = 20 * 1024 * 1024
    ) {
        let directory = directory
        
        let (exists, isDirectory) = directory.exists
        if exists {
            guard isDirectory else {
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
    }
    
    open func deleteOldFiles() {
        let cmp = { (a: URL, b: URL) -> Bool in
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
        
        DispatchQueue.global(qos: .background).async(execute: body)
    }
    
    open func stream(_ stream: FileLogOutputStream, fileToOutput logEntry: ProcessedLogEntry<Data>, currentFile: URL?) throws -> URL? {
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
    
    open override func stream(_ stream: FileLogOutputStream, fileToOutput logEntry: ProcessedLogEntry<Data>, currentFile: URL?) throws -> URL? {
        let date = logEntry.rawLogEntry.date
        let filename = Self.formatter.string(from: date) + ".log"
        
        if let currentFile = currentFile, currentFile.filename == filename {
            return currentFile
        }
        
        let file = directory.appendingPathComponent(filename)
        if !file.exists.exists {
            _ = file.create()

            deleteOldFiles()
            
            return file
        }
        
        return file
    }
}

private extension URL {
    
    var attributes: [FileAttributeKey: Any]? {
        try? fileManager.attributesOfItem(atPath: absoluteString)
    }
     
    var modificationDate: Date? {
        attributes?[.modificationDate] as? Date
    }
    
    var size: UInt64? {
        attributes?[.size] as? UInt64
    }

    var exists: (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false
        let exist = fileManager.fileExists(atPath: absoluteString, isDirectory: &isDirectory)
        return (exist, isDirectory.boolValue)
    }
    
    func createDirectory() -> Bool {
        do {
            try fileManager.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    var contents: [URL]? {
        try? fileManager
            .contentsOfDirectory(atPath: absoluteString)
            .map { URL(fileURLWithPath: $0) }
    }
    
    func delete() -> Bool {
        do {
            try fileManager.removeItem(at: self)
            return true
        } catch {
            return false
        }
    }
    
    func create() -> Bool {
        fileManager.createFile(atPath: absoluteString, contents: nil, attributes: nil)
    }
    
    var filename: String {
        lastPathComponent
    }
}
