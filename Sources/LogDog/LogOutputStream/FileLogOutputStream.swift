import Foundation

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
            
            guard let outputStream = file.outputStream(append: true) else {
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
    
    public static let defaultDirectory: Path = {
        #if os(iOS) || os(tvOS) || os(watchOS)
        return Path.userCaches + "Logs"
        #else
        let processName = ProcessInfo.processInfo.processName
        return Path.userLibrary + "Logs" + processName
        #endif
    }()
}

open class AbstractRotator: FileLogOutputStreamDelegate {
    
    public let directory: Path
    public let directoryCountLimit: Int
    public let directorySizeLimit: UInt64
    
    public init?(
        directory: Path = FileLogOutputStream.defaultDirectory,
        directoryCountLimit: Int = 5,
        directorySizeLimit: UInt64 = 20 * 1024 * 1024
    ) {
        let directory = directory.resolved
        
        if directory.exists {
            guard directory.isDirectory else { return nil }
        } else {
            try? directory.createDirectory()
        }
        
        self.directory = directory
        self.directoryCountLimit = directoryCountLimit
        self.directorySizeLimit = directorySizeLimit
    }
    
    open func deleteOldFiles() {
        let cmp = { (a: Path, b: Path) -> Bool in
            guard let a = a.modificationDate, let b = b.modificationDate else { return false }
            return a > b
        }
        
        let directory = self.directory
        let directoryCountLimit = self.directoryCountLimit
        let directorySizeLimit = self.directorySizeLimit
        
        let body = {
            let files = directory.children().sorted(by: cmp)
            var firstIndexToDelete = -1
            
            if directorySizeLimit != .max {
                var size: UInt64 = 0
                for (index, file) in files.enumerated() {
                    size += (file.fileSize ?? 0)
                    
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
                try? files[firstIndexToDelete].deleteFile()
                firstIndexToDelete += 1
            }
        }
        
        DispatchQueue.global(qos: .background).async(execute: body)
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
        
        if let currentFile = currentFile, currentFile.fileName == filename {
            return currentFile
        }
        
        let file = directory + filename
        if !file.exists {
            try file.createFile()

            deleteOldFiles()
            
            return file
        }
        
        return file
    }
}
