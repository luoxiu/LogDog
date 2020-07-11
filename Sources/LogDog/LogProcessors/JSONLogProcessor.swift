import Foundation

open class JSONLogProcessor: LogProcessor<Void, Data> {
    
    public init() {
        super.init { logEntry in
            try logEntry.map {
                try JSONEncoder().encode(logEntry.raw)
            }
        }
    }
}
