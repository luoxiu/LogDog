import Foundation

open class JSONLogFromatter: LogFormatter<Void, Data> {
    
    public init() {
        super.init { logEntry in
            try logEntry.map {
                try JSONEncoder().encode(logEntry.origin)
            }
        }
    }
}
