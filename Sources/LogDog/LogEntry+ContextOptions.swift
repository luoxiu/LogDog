//
//  File.swift
//  
//
//  Created by jinxiangqiu on 2020/7/7.
//

#if canImport(Darwin)
import Darwin
#endif

public extension LogEntry {
    
    struct ContextOptions: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let threadId = ContextOptions(rawValue: 1)
    }
}
