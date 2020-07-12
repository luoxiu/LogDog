import Foundation

extension String {
    
    var lastPathComponent: String {
        NSString(string: self).lastPathComponent
    }
    
    var deletingPathExtension: String {
        NSString(string: self).deletingPathExtension
    }
}
